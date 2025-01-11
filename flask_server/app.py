from flask import Flask, render_template
import firebase_admin
from firebase_admin import credentials, storage

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('trial.html')

if __name__ == '__main__':
    app.run(debug=True)

def upload_docs():


    # Initialize the Firebase app
    cred = credentials.Certificate("path/to/your/serviceAccountKey.json")
    firebase_admin.initialize_app(cred, {
        'storageBucket': 'invest-buddies.appspot.com'
    })

    # Reference to your Firebase Storage bucket
    bucket = storage.bucket()

    # File to upload
    local_file_path = "path/to/your/file.txt"
    blob = bucket.blob("folder_name_in_storage/file.txt")

    # Upload the file
    blob.upload_from_filename(local_file_path)

    print(f"File uploaded successfully to {blob.public_url}")

