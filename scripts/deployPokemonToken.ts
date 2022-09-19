import { ethers } from "hardhat";

async function main() {
  const PokemonTokenFactory = await ethers.getContractFactory("PokemonToken");
  const pokemonToken = await PokemonTokenFactory.deploy("0x5Dd4766194c6a2E5C4994DD52D75909a37c12E91", "0x26f9A1b798F848F10A8e83bdD874f29055FF856b", "0xe2226bA8B8Da6a2edf1878d823f479B64B18DCa8");

  await pokemonToken.deployed();

  console.log("PokemonToken address: ", pokemonToken.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});