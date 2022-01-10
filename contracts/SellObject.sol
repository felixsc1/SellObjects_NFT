// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SellObject is ERC721, ERC721URIStorage, Ownable {
    uint256 public tokenCounter;
    IERC20 public autiCoin;
    // for now, one fixed price as global variable and from that a 10% royalty fee
    uint256 public NFTprice;
    uint256 public TxFee;

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

    function setNFTPrice(uint256 _newPrice, uint256 _feePercentage)
        public
        onlyOwner
    {
        NFTprice = _newPrice;
        // Use a fixed 10% royalty fee
        TxFee = (_newPrice / 100) * _feePercentage;
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

    // The following functions are overrides required by Solidity (even thouhg nothing is changed hered)

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

    // For the royalties/taxation version, we override all NFT transfer functions:

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _payTxFee(from);
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _payTxFee(from);
        _safeTransfer(from, to, tokenId, _data);
    }

    // 1. Buyer transfers tokens to contract
    function payTokens(uint256 _amount) public payable {
        // could add require statement for minimum amount, but like this it allows multiple partial payments.
        autiCoin.transferFrom(msg.sender, address(this), _amount);
        autiCoinBalance[msg.sender] += _amount;
    }

    // 2. Seller finalizes the order
    // Using this function, royalty fee is subtracted from the buyers funds, NFT holder doesnt need auticoins themselves.
    function sellItem(address _to, uint256 _tokenId) public {
        require(
            autiCoinBalance[_to] >= NFTprice,
            "Buyer has insufficient funds!"
        );
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        // autiCoin.transferFrom(address(this), msg.sender, NFTprice); this doesnt work, not sure why...
        autiCoinBalance[_to] -= NFTprice;
        autiCoin.transfer(owner(), TxFee);
        autiCoin.transfer(msg.sender, NFTprice - TxFee);
        // here we directly call the internal _transfer function, or else seller would pay the royalties twice.
        _transfer(msg.sender, _to, _tokenId);
    }

    // Whenever the NFT owner transfers the token he must pay the royalty fee in auticoins from his own wallet.
    // royalties are transferred to the owner of this contract
    function _payTxFee(address from) internal {
        autiCoin.transferFrom(from, owner(), TxFee);
    }
}
