# Smart Contract to sell non-fungible tokens

As a starting point we use the tested openzeppelin ERC-721 contract with several extensions.

The smart contract *SellObject.sol* allows the owner to mint NFTs (representing real world objects), providing name, description and image.
The metadata and images are stored on IPFS.


## Setup

To run the deployment scripts, install [brownie](https://eth-brownie.readthedocs.io/en/stable/install.html).

To deploy contracts on live testnets, create an .env file with the enironmental variables shown in *.env_example*

The NFT metadata are stored on IPFS via [Pinata](https://www.pinata.cloud/). This requires to sign up for a (free) account and creating an API key.

## Usage

See ./tests/test_sellObject.py for how to deploy and run the individual functions.

- The owner of the contract can mint NFT tokens and set the price.
- Anyone can pay "Auticoins" to the contract via the *payTokens()* function.
- The owner of an NFT can then call the *sellItem()* function to transfer the NFT to another address (which must have sufficient Auticoins on the contract), and receives the sale price to his address.

*SellObjectNoFee.sol* is the simplified version of the NFT contract, without the payment and royalty fee mechanics.

## Update: Royalties

With setNFTPrice() a percentage of the NFT price can now be set as royalty fee. For every transfer of the NFT, this amount will be sent to the wallet of the contract's owner.
Note: When selling via the sellItem() function royalties will be automatically subtracted from the buyer's funds. When transferring the NFT via the transferFrom() function, royalties have to be paid from the token holder's wallet.
  

Sidenote: when deploying the contract to the rinkeby testnet, NFTs will automatically appear on the [opensea](https://opensea.io/) platform for sale.
![opensea_example](./img/opensea_example.PNG)