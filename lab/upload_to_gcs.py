import os
from pathlib import Path
from gcloud import storage
from oauth2client.service_account import ServiceAccountCredentials


BUCKET_NAME = os.getenv("BUCKET_NAME")
PROJECT_ID = os.getenv("PROJECT_ID")
DWH_DATA_PATH = os.getenv('DWH_DATA')
MARTS_PATH = Path(DWH_DATA_PATH, 'marts')


def get_object_suffix(path:Path) -> Path:
    return path.relative_to(DWH_DATA_PATH)


def get_credentials():
    ...


def get_gcs_client() -> storage.Client:
    return storage.Client(
        project=PROJECT_ID
    )


def get_bucket():
    client = get_gcs_client()
    return client.get_bucket(BUCKET_NAME)


def upload_folder_files_to_bucket(folder_path):
    bucket = get_bucket()
    for file_path in folder_path:
        object_suffix = get_object_suffix(file_path)
        blob = bucket.blob(object_suffix)
        blob.upload_from_filename(file_path)


if __name__ == "__main__":
    upload_folder_files_to_bucket(MARTS_PATH)