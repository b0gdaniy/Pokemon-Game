import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { PokemonLevelToken, PokemonLevelToken__factory } from "../typechain-types";

describe("PokemonLevelToken", async () => {

	async function deploy() {
		const [deployer, customer] = await ethers.getSigners();

		const PokemonLevelTokenFactory = await ethers.getContractFactory("PokemonLevelToken");
		const pokemonLevelToken: PokemonLevelToken = await PokemonLevelTokenFactory.deploy();
		await pokemonLevelToken.deployed();

		return { pokemonLevelToken, deployer, customer };
	}

	it("deployed correctly", async () => {
		const { pokemonLevelToken } = await loadFixture(deploy);
		expect(pokemonLevelToken.address).to.be.properAddress;
	})

	it("deployed with correct name", async () => {
		const { pokemonLevelToken } = await loadFixture(deploy);

		expect(await pokemonLevelToken.name()).to.eq("PokemonLevel");
		expect(await pokemonLevelToken.symbol()).to.eq("PLVL");
	})

	it("minted correctly", async () => {
		const { pokemonLevelToken, deployer, customer } = await loadFixture(deploy);

		const oneWei = 1;

		await expect(pokemonLevelToken.connect(customer).mint(customer.address, oneWei))
			.to.be.revertedWith("Ownable: caller is not the owner");

		await expect(() => pokemonLevelToken.mint(deployer.address, oneWei))
			.to.changeTokenBalance(pokemonLevelToken, deployer.address, oneWei);
	})

	it("burned correctly", async () => {
		const { pokemonLevelToken, deployer, customer } = await loadFixture(deploy);

		const wei25 = 25;

		await (await pokemonLevelToken.mint(deployer.address, wei25)).wait();

		await expect(() => pokemonLevelToken.burn(wei25))
			.to.changeTokenBalance(pokemonLevelToken, deployer.address, -wei25);
	})

	it("received correctly", async () => {
		const { pokemonLevelToken, deployer, customer } = await loadFixture(deploy);

		await expect(await deployer.sendTransaction({
			to: pokemonLevelToken.address,
			value: 1
		}))
			.to.changeTokenBalance(pokemonLevelToken, deployer.address, ethers.utils.parseEther('1'));

		await expect(await customer.sendTransaction({
			to: pokemonLevelToken.address,
			value: 1
		}))
			.to.changeTokenBalance(pokemonLevelToken, customer.address, ethers.utils.parseEther('1'));
	})

	it("withdraws corectly", async () => {
		const { pokemonLevelToken, deployer, customer } = await loadFixture(deploy);

		await expect(pokemonLevelToken.withdraw(1))
			.to.be.revertedWith("Not enough funds");
		await expect(pokemonLevelToken.withdrawAll())
			.to.be.revertedWith("Not enough funds");

		await deployer.sendTransaction({
			to: pokemonLevelToken.address,
			value: 3
		});
		await customer.sendTransaction({
			to: pokemonLevelToken.address,
			value: 1
		});

		await expect(pokemonLevelToken.connect(customer).withdraw(1))
			.to.be.revertedWith("Ownable: caller is not the owner");
		await expect(pokemonLevelToken.connect(customer).withdraw(1))
			.to.be.revertedWith("Ownable: caller is not the owner");

		await expect(await pokemonLevelToken.withdraw(1))
			.to.changeEtherBalances([deployer.address, pokemonLevelToken.address], [1, -1]);
		await expect(await pokemonLevelToken.withdrawAll())
			.to.changeEtherBalances([deployer.address, pokemonLevelToken.address], [3, -3]);
	})
})
