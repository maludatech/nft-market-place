const hre = require("hardhat");

async function main() {
    const NftMarketPlace = await hre.ethers.getContractFactory("NFTMarketPlace");
    const nftMarketPlace = await NftMarketPlace.deploy();

    await nftMarketPlace.deployed();

    console.log(`nftMarketPlace with 1 ETH deployed to ${nftMarketPlace.address}`);
}

main().catch((error) => {
        console.error(error);
        process.exit(1);
    })