// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "hardhat/console.sol";

import {
    ERC721URIStorage,
    ERC721
} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMarketPlace is ERC721URIStorage {
    uint256 private _tokenId;
    uint256 private _itemsSold;

    address payable owner;

    constructor() ERC721("NFTMarketPlace", "NMP") {}

    mapping(uint256 => MarketItem) private idMarketItem;

    struct MarketItem {
        address payable seller;
        uint256 price;
        bool sold;
    }
}
