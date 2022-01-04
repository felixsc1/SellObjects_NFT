// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SellObject is ERC721, ERC721URIStorage, Ownable {
    uint256 public tokenCounter;
    IERC20 public autiCoin;
    // for now, one fixed price as global variable
    uint256 public NFTprice;

    // keeping track of auticoin balances
    mapping(address => uint256) public autiCoinBalance;

    constructor(address _autiCoinAddress) ERC721("SellObject", "SO") {
        tokenCounter = 0;
        autiCoin = IERC20(_autiCoinAddress);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "";
    }

    //  first we create new Token (Object to sell) with unique ID, without setting the tokenURI yet
    // owner is the msg.sender
    function createNewToken() public onlyOwner {
        uint256 newTokenId = tokenCounter;
        _safeMint(msg.sender, newTokenId);
        tokenCounter++;
    }

    // next we provide the URI
    function setTokenURI(uint256 tokenId, string memory _tokenURI)
        public
        onlyOwner
    {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: Caller is not owner nor approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }

    function setNFTPrice(uint256 _newPrice) public onlyOwner {
        NFTprice = _newPrice;
    }

    // this function would do both previous steps at once.
    function safeMint(
        address to,
        uint256 tokenId,
        string memory uri
    ) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    // 1. Buyer transfers tokens to contract
    function payTokens(uint256 _amount) public payable {
        // could add require statement for price, but like this it allows multiple partial payments.
        autiCoin.transferFrom(msg.sender, address(this), _amount);
        autiCoinBalance[msg.sender] += _amount;
    }

    // 2. Seller finalizes the order
    function sellItem(address _to, uint256 _tokenId) public {
        require(
            autiCoinBalance[_to] >= NFTprice,
            "Buyer has insufficient funds!"
        );
        require(
            ownerOf(_tokenId) == msg.sender,
            "You are not the owner of the token!"
        );
        // autiCoin.transferFrom(address(this), msg.sender, NFTprice); this doesnt work, not sure why...
        autiCoin.transfer(msg.sender, NFTprice);
        autiCoinBalance[_to] -= NFTprice;
        safeTransferFrom(msg.sender, _to, _tokenId);
    }
}
