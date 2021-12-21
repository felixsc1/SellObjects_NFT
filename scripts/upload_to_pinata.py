import os
import requests
from pathlib import Path

PINATA_BASE_URL = 'https://api.pinata.cloud'
endpoint = "/pinning/pinFileToIPFS"
# See: https://docs.pinata.cloud/api-pinning/pin-file

# change this filepath:
# filepath = "./img/pug.png"
# filename = filepath.split("/")[-1][0]

headers = {"pinata_api_key": os.getenv(
    "PINATA_API_KEY"), "pinata_secret_api_key": os.getenv("PINATA_API_SECRET")}


def upload_to_pinata(filepath):
    filename = filepath.split("/")[-1:][0]
    with Path(filepath).open("rb") as fp:
        image_binary = fp.read()
        response = requests.post(PINATA_BASE_URL + endpoint,
                                 files={"file": (filename, image_binary)}, headers=headers)
        print(response.json())
        # response doesnt contain the full link, thus have to re-create it
        ipfs_hash = response.json()["IpfsHash"]
        image_uri = f"https://ipfs.io/ipfs/{ipfs_hash}?filename={filename}"
        print(image_uri)
    return image_uri
