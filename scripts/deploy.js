const hre = require("hardhat");

async function main() {
  const NFTMarketPlace = await hre.ethers.getContractFactory("NFTMarketPlace");
  const nftMarketPlace = await NFTMarketPlace.deploy();

  await nftMarketPlace.deployed();

  console.log(
    `nftMarketPlace with 1 ETH deployed to ${nftMarketPlace.address}`,
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
