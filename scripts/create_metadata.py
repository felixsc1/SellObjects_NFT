from brownie import network
from scripts.upload_to_pinata import upload_to_pinata
import json
from pathlib import Path

metadata_template = {
    "name": "",
    "description": "",
    "image": "",
    "attributes": [{"trait_type": "environmental_friendliness", "value": 100}]
}


def create_metadata(token_id, _name, _description, _image):
    """
    _image is e.g. ""./img/schal.jpg"
    two upload steps: first upload the image to get image_uri, then upload metadata json file
    """
    metadata_file_name = f"./metadata/{network.show_active()}/{token_id}.json"
    if Path(metadata_file_name).exists():
        print(f"{metadata_file_name} already exists! Delete it to overwrite")
    else:
        print(f"Creating metadata for item {token_id}")
        item_metadata = metadata_template
        item_metadata["name"] = _name
        item_metadata["description"] = _description
        image_uri = upload_to_pinata(_image)
        item_metadata["image"] = image_uri
        # now we have all data to create metadata json file:
        with open(metadata_file_name, "w") as file:
            json.dump(item_metadata, file)
        tokenURI = upload_to_pinata(metadata_file_name)
        return tokenURI
