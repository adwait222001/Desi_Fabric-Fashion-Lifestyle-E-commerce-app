from flask import Flask, request, jsonify, send_from_directory
import os
import json
import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from nltk.stem.porter import PorterStemmer

app = Flask(__name__)

# === Configuration ===
SORTED_FOLDER = r"C:\Users\Admin\Desktop\rangmahal (2)\rangmahal\server_code\data\sorted_data"

# === Load and clean Excel data ===
men = pd.read_excel("mencasual.xlsx", sheet_name="Tshirts")
women = pd.read_excel("womencasual.xlsx", sheet_name="Tshirts")
stemmer = PorterStemmer()

def clean_dataframe(df):
    df = df.copy()
    df.columns = df.columns.str.strip().str.lower()

    df['brandname'] = df['brandname'].astype(str).str.strip().str.lower()
    df['imagename'] = df['imagename'].astype(str).str.strip().str.lower()
    df['gender'] = df['gender'].astype(str).str.strip().str.lower()

    if 'colour' in df.columns:
        df['colour'] = df['colour'].astype(str).str.strip().str.lower()
    else:
        df['colour'] = ''

    if 'productdescriptors' in df.columns:
        df['descriptors'] = df['productdescriptors'].astype(str).str.strip().str.lower()
    else:
        df['descriptors'] = ''

    df['price'] = pd.to_numeric(df['price'], errors='coerce').astype('Int64')
    df['id'] = pd.to_numeric(df['id'], errors='coerce').astype('Int64')

    return df

# Clean both dataframes
men = clean_dataframe(men)
women = clean_dataframe(women)

# Merge datasets
final = pd.merge(men, women, on=["brandname", "price", "imagename", "id", "descriptors", "gender", "colour"], how="outer")

# Create tags
def create_tags(row):
    return f"{row['brandname']} {row['descriptors']} {row['colour']} {row['gender']}"

final['tags'] = final.apply(create_tags, axis=1)

# Vectorize tags and compute similarity
vectorizer = CountVectorizer(max_features=5000, stop_words='english')
vectors = vectorizer.fit_transform(final['tags']).toarray()
similarity = cosine_similarity(vectors)

# === Modified Recommendation Logic ===
def recommend_tshirt(brand_name):
    try:
        brand_name = brand_name.lower()

        def get_top_n_by_gender(gender_df):
            gender_indices = gender_df.index.tolist()
            brand_matches = gender_df[gender_df['brandname'] == brand_name]
            if brand_matches.empty:
                return []

            idx = brand_matches.index[0]
            distances = list(enumerate(similarity[idx]))
            distances = [d for d in distances if d[0] in gender_indices and d[0] != idx]
            sorted_distances = sorted(distances, key=lambda x: x[1], reverse=True)

            seen = set()
            brand_count = {}
            recs = []

            for i in sorted_distances:
                row = final.iloc[i[0]]
                image = row['imagename']
                brand = row['brandname']

                if image in seen:
                    continue

                if brand_count.get(brand, 0) >= 3:
                    continue

                recs.append(image)
                seen.add(image)
                brand_count[brand] = brand_count.get(brand, 0) + 1

                if len(recs) == 5:
                    break

            return recs

        men_df = final[final['gender'] == 'men']
        women_df = final[final['gender'] == 'women']

        men_recs = get_top_n_by_gender(men_df)
        women_recs = get_top_n_by_gender(women_df)

        # Interleave: 2 men → 2 women
        result = []
        men_idx = women_idx = 0

        while men_idx < len(men_recs) or women_idx < len(women_recs):
            for _ in range(2):
                if men_idx < len(men_recs):
                    result.append(men_recs[men_idx])
                    men_idx += 1
            for _ in range(2):
                if women_idx < len(women_recs):
                    result.append(women_recs[women_idx])
                    women_idx += 1

        return result[:10]  # Max 10 results

    except Exception as e:
        print("Error in recommend_tshirt:", e)
        return []

# === Image Info Fetcher ===
def get_image_info(image_names):
    results = []
    for image_name in image_names:
        image_base = image_name.replace(".jpg", "").replace(".png", "")
        found = False
        for gender in os.listdir(SORTED_FOLDER):
            gender_path = os.path.join(SORTED_FOLDER, gender)
            if not os.path.isdir(gender_path):
                continue
            for article in os.listdir(gender_path):
                article_path = os.path.join(gender_path, article)
                if not os.path.isdir(article_path):
                    continue
                for ext in ['.jpg', '.png']:
                    image_file = os.path.join(article_path, image_base + ext)
                    json_file = os.path.join(article_path, image_base + '.json')
                    if os.path.exists(image_file):
                        product_data = {}
                        style_images = []
                        if os.path.exists(json_file):
                            with open(json_file, 'r', encoding='utf-8') as f:
                                content = json.load(f)
                                data = content.get("data", {})
                                product_data = {
                                    "price": data.get("price", "N/A"),
                                    "discountedPrice": data.get("discountedPrice", "N/A"),
                                    "productName": data.get("productDisplayName", "Unknown"),
                                    "brand": data.get("brandName", "Unknown"),
                                }

                                # Extract styleImages
                                style_dict = data.get("styleImages", {})
                                for style_key in ["front", "back", "left", "right", "default"]:
                                    style_data = style_dict.get(style_key, {})
                                    style_url = style_data.get("imageURL")
                                    if style_url:
                                        style_images.append({
                                            "type": style_key,
                                            "url": style_url
                                        })

                        results.append({
                            "image_name": image_base,
                            "gender": gender,
                            "image_url": f"http://192.168.29.214:5000/images/{gender}/{article}/{image_base + ext}",
                            "product_info": product_data,
                            "styleImages": style_images
                        })
                        found = True
                        break
                if found:
                    break
            if found:
                break
        if not found:
            results.append({
                "image_name": image_base,
                "error": "Image not found"
            })
    return results

# === API Endpoints ===
@app.route('/recommend', methods=['GET'])
def recommend_api():
    brand = request.args.get("brand")
    if not brand:
        return jsonify({"error": "Missing brand name"}), 400

    image_names = recommend_tshirt(brand)
    image_info = get_image_info(image_names)
    return jsonify({"recommended": image_info})

@app.route('/images/<gender>/<article>/<filename>')
def serve_image(gender, article, filename):
    path = os.path.join(SORTED_FOLDER, gender, article)
    return send_from_directory(path, filename)

# === Run App ===
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
