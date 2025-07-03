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
        owner = payable(msg.sender);
    }

    function updateListingPrice(
        uint256 _listingPrice
    ) public payable onlyOwner {
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    //function to create NFT token
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

    //function to create market item
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

    //function for re-sale token
    function resaleToken(uint256 tokenId, uint256 price) public payable {
        require(
            idMarketItem[tokenId].owner == msg.sender,
            "Only item owner can perform this operation"
        );
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        idMarketItem[tokenId].price = price;
        idMarketItem[tokenId].sold = false;
        idMarketItem[tokenId].seller = payable(msg.sender);
        idMarketItem[tokenId].owner = payable(address(this));

        if (_itemsSold > 0) {
            _itemsSold -= 1;
        }

        _transfer(msg.sender, address(this), tokenId);
    }

    //function for create market sale
    function createMarketSale(uint256 tokenId) public payable {
        uint256 price = idMarketItem[tokenId].price;

        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );

        idMarketItem[tokenId].owner = payable(msg.sender);
        idMarketItem[tokenId].sold = true;

        _itemsSold += 1;

        _transfer(address(this), msg.sender, tokenId);

        payable(owner).transfer(listingPrice);
        payable(idMarketItem[tokenId].seller).transfer(msg.value);
    }

    //function to get unsold NFT data
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds;
        uint256 unSoldItemCount = _tokenIds - _itemsSold;
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unSoldItemCount); //unSoldItemCount represents the length of the array

        for (uint256 i = 1; i <= itemCount; i++) {
            if (idMarketItem[i].sold == false) {
                items[currentIndex] = MarketItem({
                    tokenId: idMarketItem[i].tokenId,
                    seller: idMarketItem[i].seller,
                    owner: idMarketItem[i].owner,
                    price: idMarketItem[i].price,
                    sold: idMarketItem[i].sold
                });
                currentIndex++;
            }
        }
        return items;
    }

    //fucntion to get total items
    function getTotalItems() public view returns (uint256) {
        return _tokenIds;
    }

    //function to fetch your purchased item
    function fetchMyNFT() public view returns (MarketItem[] memory) {
        uint256 totalCount = _tokenIds;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= totalCount; i++) {
            if (idMarketItem[i].owner == msg.sender) {
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 1; i <= totalCount; i++) {
            if (idMarketItem[i].owner == msg.sender) {
                items[currentIndex] = MarketItem({
                    tokenId: idMarketItem[i].tokenId,
                    seller: idMarketItem[i].seller,
                    owner: idMarketItem[i].owner,
                    price: idMarketItem[i].price,
                    sold: idMarketItem[i].sold
                });
                currentIndex++;
            }
        }
        return items;
    }

    //function to fetch items created by users
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint256 totalCount = _tokenIds;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= totalCount; i++) {
            if (idMarketItem[i].seller == msg.sender) {
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 1; i <= totalCount; i++) {
            if (idMarketItem[i].seller == msg.sender) {
                items[currentIndex] = MarketItem({
                    tokenId: idMarketItem[i].tokenId,
                    seller: idMarketItem[i].seller,
                    owner: idMarketItem[i].owner,
                    price: idMarketItem[i].price,
                    sold: idMarketItem[i].sold
                });
                currentIndex++;
            }
        }
        return items;
    }
}
