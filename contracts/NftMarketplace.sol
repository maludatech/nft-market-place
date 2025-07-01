// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "hardhat/console.sol";

import {
    ERC721URIStorage,
    ERC721
} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMarketPlace is ERC721URIStorage {
    uint256 private _tokenIds;
    uint256 private _itemsSold;
    uint256 public listingPrice = 0.0025 ether;

    address payable owner;

    mapping(uint256 => MarketItem) private idMarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event idMarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "only owner of the marketplace can change the listing price"
        );
        _;
    }

    constructor() ERC721("NFT Metaverse Token", "NMT") {
        owner == payable(msg.sender);
    }

    function updateListingPrice(
        uint256 _listingPrice
    ) public payable onlyOwner {
        _listingPrice = listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    //Create NFT token function
    function createToken(
        string memory tokenURI,
        uint256 price
    ) public payable returns (uint256) {
        _tokenIds += 1;
        uint256 newTokenId = _tokenIds;
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createMarketItem(newTokenId, price);

        return newTokenId;
    }

    //Create Market Item function
    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be greater than 0");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        idMarketItem[tokenId] = MarketItem({
            tokenId: tokenId,
            seller: payable(msg.sender),
            owner: payable(owner),
            price: price,
            sold: false
        });

        _transfer(msg.sender, address(this), tokenId);

        emit idMarketItemCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false
        );
    }
}
