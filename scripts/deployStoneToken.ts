import { ethers } from "hardhat";

async function main() {
  const StoneTokenFactory = await ethers.getContractFactory("StoneToken");
  const stoneToken = await StoneTokenFactory.deploy();

  await stoneToken.deployed();

  console.log("StoneToken address: ", stoneToken.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});