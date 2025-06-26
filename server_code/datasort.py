import json
import os
import zipfile
import shutil

# Path to ZIP file
zip_path = r"C:\Users\Admin\Desktop\flutterprojects\archive (7).zip"

# Inside ZIP: Paths to images and JSONs
image_folder = "fashion-dataset/fashion-dataset/images"
json_folder = "fashion-dataset/fashion-dataset/styles"

# Destination sorted folder
sorted_folder = 

# Dictionary to store metadata: { (gender, articleType) : [(image_path, json_path)] }
image_metadata = {}

# Function to load metadata from ZIP without extracting permanently
def load_metadata_from_zip(zip_path):
    global image_metadata
    image_metadata.clear()  # Reset dictionary

    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        # Get JSON and Image files
        json_files = [f for f in zip_ref.namelist() if f.startswith(json_folder) and f.endswith('.json')]
        image_files = {os.path.basename(f): f for f in zip_ref.namelist() if f.startswith(image_folder) and f.endswith('.jpg')}

        for json_filename in json_files:
            with zip_ref.open(json_filename) as file:
                try:
                    content = json.load(file)
                    current = content.get('data', {})

                    # Extract and normalize values
                    gender = str(current.get('gender', 'Unknown')).strip().capitalize()

                    # Extract articleType
                    article_data = current.get('articleType', {})
                    article_values = list(article_data.values())

                    if len(article_values) > 1:
                        article_type = str(article_values[1]).strip().capitalize()
                    else:
                        article_type = "Unknown"

                    # Remove invalid characters for folder names
                    article_type = article_type.replace("/", "-").replace("\\", "-").replace(":", "-").replace("*", "").replace("?", "").replace("\"", "").replace("<", "").replace(">", "").replace("|", "")

                    # Get corresponding image filename
                    base_filename = os.path.basename(json_filename).replace(".json", ".jpg")
                    if base_filename in image_files:
                        image_filename = image_files[base_filename]

                        key = (gender, article_type)
                        if key not in image_metadata:
                            image_metadata[key] = []
                        image_metadata[key].append((image_filename, json_filename))
                    
                    # Debug print to verify extracted values
                    print(f"JSON: {json_filename} → Gender: {gender}, ArticleType: {article_type}")

                except Exception as e:
                    print(f"Error reading {json_filename}: {e}")

    print(f"✅ Total categories found: {len(image_metadata)}")

# Function to create folders and move limited samples
def sort_and_store_files(zip_path, sorted_folder, limit=50):
    os.makedirs(sorted_folder, exist_ok=True)

    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        for (gender, article_type), files in image_metadata.items():
            # Limit samples to 50 per category
            selected_files = files[:limit]

            # Define folder paths
            gender_folder = os.path.join(sorted_folder, gender)
            article_folder = os.path.join(gender_folder, article_type)

            os.makedirs(article_folder, exist_ok=True)

            for image_file, json_file in selected_files:
                # Extract and move image
                with zip_ref.open(image_file) as img_src:
                    img_dest_path = os.path.join(article_folder, os.path.basename(image_file))
                    with open(img_dest_path, "wb") as img_dest:
                        shutil.copyfileobj(img_src, img_dest)

                # Extract and move JSON
                with zip_ref.open(json_file) as json_src:
                    json_dest_path = os.path.join(article_folder, os.path.basename(json_file))
                    with open(json_dest_path, "wb") as json_dest:
                        shutil.copyfileobj(json_src, json_dest)

            print(f"✔ Moved {len(selected_files)} samples for {gender} → {article_type}")

# Run the functions
if __name__ == '__main__':
    load_metadata_from_zip(zip_path)  # Load metadata
    print(f"Total categories found: {len(image_metadata)}")
    
    sort_and_store_files(zip_path, sorted_folder, limit=50)  # Sort & move files
    print("✅ Sorting completed successfully!")
