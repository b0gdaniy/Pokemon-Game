import { ethers } from "hardhat";

async function main() {
  const PokemonLevelTokenFactory = await ethers.getContractFactory("PokemonLevelToken");
  const pokemonLevelToken = await PokemonLevelTokenFactory.deploy();

  await pokemonLevelToken.deployed();

  console.log("PokemonLevelToken address: ", pokemonLevelToken.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});