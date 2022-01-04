from scripts.deploy_and_create import deploy, createNFT
from scripts.helpful_scripts import get_account


def test_pay_auticoins(current_price):
    # Arrange
    account = get_account()
    auticoin, sell_object = deploy()
    # Act
    auticoin.approve(sell_object.address, current_price, {"from": account})
    sell_object.payTokens(current_price, {"from": account})
    # Assert
    assert sell_object.autiCoinBalance(account.address) == current_price
    assert auticoin.balanceOf(sell_object.address) == current_price


def test_create_and_transfer_NFT():
    # Arrange
    owner_account = get_account()
    receiver_account = get_account(index=1)
    print(
        f"owner: {owner_account.address}, receiver: {receiver_account.address}")
    auticoin, sell_object = deploy()
    # Act
    createNFT()
    tokenId = sell_object.tokenCounter()-1
    sell_object.safeTransferFrom(owner_account, receiver_account, tokenId)
    # Assert
    assert sell_object.ownerOf(tokenId) == receiver_account.address


def test_finalize_sale(current_price):
    # ARRANGE (everything from previous tests)
    admin = get_account()
    stefan = get_account(index=1)
    lukas = get_account(index=2)
    auticoin, sell_object = deploy()
    # Give Lukas the coins
    auticoin.transfer(lukas, current_price, {"from": admin})
    # Lukas pays to the contract
    auticoin.approve(sell_object.address, current_price, {"from": lukas})
    sell_object.payTokens(current_price, {"from": lukas})
    # Create and give Stefan the NFT
    createNFT()
    # Dont forget to set NFT price
    sell_object.setNFTPrice(current_price, {"from": admin})
    tokenId = sell_object.tokenCounter()-1
    sell_object.safeTransferFrom(admin, stefan, tokenId)
    # quick check if Stefan is now owner
    assert sell_object.ownerOf(tokenId) == stefan.address
    # ACT
    sell_object.sellItem(lukas.address, tokenId, {"from": stefan})
    # ASSERT
    # Lukas should now own the NFT
    assert sell_object.ownerOf(tokenId) == lukas.address
    # Stefan should have received the coins from the contract
    assert auticoin.balanceOf(sell_object.address) == 0
    assert auticoin.balanceOf(stefan.address) == current_price
