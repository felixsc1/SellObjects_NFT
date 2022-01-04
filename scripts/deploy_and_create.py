from brownie import SellObject, AutiCoin, network, config
from scripts.helpful_scripts import get_account, OPENSEA_URL
from scripts.create_metadata import create_metadata

# This is the main scripts, the others contained functions that will be called here


def deploy():
    account = get_account()
    auticoin = AutiCoin.deploy({"from": account})
    sell_object = SellObject.deploy(auticoin.address,
                                    {"from": account}, publish_source=config["networks"][network.show_active()].get("verify"))
    return auticoin, sell_object


def createNFT():
    # creates an empty NFT, with unique ID but without any metadata yet.
    account = get_account()
    sell_object = SellObject[-1]
    tx = sell_object.createNewToken({"from": account})
    tx.wait(1)
    print(f"Created new Object with ID {sell_object.tokenCounter()}")


def setMetaData(_name, _description, _image):
    account = get_account()
    # will always set metadata of the latest token
    sell_object = SellObject[-1]
    # -1 for tokenId, because index starts at 0, but counter will give 1
    tokenId = sell_object.tokenCounter() - 1
    tokenURI = create_metadata(tokenId, _name, _description, _image)
    tx = sell_object.setTokenURI(tokenId, tokenURI, {"from": account})
    tx.wait(1)
    print(
        f"You can view your item at {OPENSEA_URL.format(sell_object.address, tokenId)}")


def main():
    deploy()
    createNFT()
    # first test the two functions above on development network, then everything on testnet
    # setMetaData('Schal', 'Recycled Kaschmir', './img/Schal.png')
