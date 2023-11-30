import os
import hashlib
import shutil

file_names = []

def md5_hash_file(file_path):
    hasher = hashlib.md5()
    with open(file_path, 'rb') as file:
        for chunk in iter(lambda: file.read(4096), b''):
            hasher.update(chunk)
    return hasher.hexdigest()

def rename_files(directory):
    for filename in os.listdir(directory):
        # Don't touch the defaults
        if filename not in ["ritual.jpg", "sprint.jpg", "highlight.jpg"]:
            file_path = os.path.join(directory, filename)
            
            # Calculate MD5 hash
            md5_hash = md5_hash_file(file_path)[0:5]
            _, file_extension = os.path.splitext(filename)
            
            # Construct new file name using MD5 hash
            new_filename = md5_hash + file_extension
            new_file_path = os.path.join(directory, new_filename)

            file_names.append(new_file_path)
            
            # Rename the file
            os.rename(file_path, new_file_path)
            print(f"Renamed {filename} to {new_filename}")

if __name__ == "__main__":
    directory_path = "assets/illustrations"
    rename_files(directory_path)

    print(file_names)
