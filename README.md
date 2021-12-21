# Smart Contract to sell non-fungible tokens

As a starting point we use the tested openzeppelin ERC-721 contract with several extensions.

The smart contract *SellObject.sol* allows the owner to mint NFTs (representing real world objects), providing name, description and image.
The metadata and images are stored on IPFS.


## Setup

To run the deployment scripts, install [brownie](https://eth-brownie.readthedocs.io/en/stable/install.html)