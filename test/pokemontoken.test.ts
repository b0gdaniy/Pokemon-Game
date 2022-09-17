import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { PokemonToken, PokemonToken__factory } from "../typechain-types";

describe("PokemonToken", async () => {

	let stoneTypes = [
		"Leaf Stone",
		"Sun Stone",
		"Water Stone",
		"Kings Rock"
	];

	async function deploy() {
		const [deployer, customer] = await ethers.getSigners();

		const PokemonLevelTokenFactory = await ethers.getContractFactory("PokemonLevelToken");
		const pokemonLevelToken = await PokemonLevelTokenFactory.deploy();
		await pokemonLevelToken.deployed();

		const StoneTokenFactory = await ethers.getContractFactory("StoneToken");
		const stoneToken = await StoneTokenFactory.deploy();
		await stoneToken.deployed();

		const PokemonTokenFactory = await ethers.getContractFactory("PokemonToken");
		const pokemonToken: PokemonToken = await PokemonTokenFactory.deploy(pokemonLevelToken.address, stoneToken.address);
		await pokemonToken.deployed();

		return { pokemonToken, deployer, customer };
	}

	// describe("Deploy", async () => {
	// 	it("deployed correctly", async () => {
	// 		const { pokemonToken } = await loadFixture(deploy);
	// 		expect(pokemonToken.address).to.be.properAddress;
	// 	})

	// 	it("deployed with correct name", async () => {
	// 		const { pokemonToken } = await loadFixture(deploy);

	// 		expect(await pokemonToken.name()).to.eq("Pokemon");
	// 		expect(await pokemonToken.symbol()).to.eq("PKMN");
	// 	})
	// })

	// describe("Tokens", async () => {
	// 	it("minted correctly", async () => {
	// 		const { stoneToken, deployer } = await loadFixture(deploy);

	// 		await expect(() => stoneToken.safeMint(deployer.address, 1))
	// 			.to.changeTokenBalance(stoneToken, deployer.address, 1);
	// 	})

	// 	it("created stone correctly", async () => {
	// 		const { stoneToken, deployer, customer } = await loadFixture(deploy);

	// 		await deployer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		});

	// 		await customer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		});

	// 		const num = 3;

	// 		await (await stoneToken.createStoneWithIndex(num)).wait();
	// 		await (await stoneToken.connect(customer).createStone()).wait();

	// 		await expect(stoneToken.createStoneWithIndex(num))
	// 			.to.be.revertedWith("You already have stone");
	// 		await expect(stoneToken.connect(customer).createStone())
	// 			.to.be.revertedWith("You already have stone");

	// 		const deployerStoneType = await stoneToken.stoneType(deployer.address);
	// 		const customerStoneType = await stoneToken.stoneType(customer.address);

	// 		expect(await stoneToken.stoneNames(deployerStoneType)).to.eq(stoneTypes[deployerStoneType]);
	// 		expect(await stoneToken.stoneNames(deployerStoneType)).to.eq(stoneTypes[num]);
	// 		expect(await stoneToken.stoneNameOf(deployer.address)).to.eq(stoneTypes[num]);

	// 		expect(await stoneToken.connect(customer).stoneNames(customerStoneType)).to.eq(stoneTypes[customerStoneType]);
	// 		expect(await stoneToken.connect(customer).stoneNameOf(customer.address)).to.eq(stoneTypes[customerStoneType]);
	// 	})

	// 	it("minted stone once", async () => {
	// 		const { stoneToken, deployer, customer } = await loadFixture(deploy);

	// 		await deployer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		});

	// 		await expect(deployer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		})).to.be.revertedWith("You already have stone token");

	// 		await customer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		});

	// 		await expect(customer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		})).to.be.revertedWith("You already have stone token");
	// 	})

	// 	it("mint => create => delete => mint", async () => {
	// 		const { stoneToken, deployer, customer } = await loadFixture(deploy);

	// 		await deployer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		});
	// 		await expect(stoneToken.safeMint(deployer.address, 0)).to.be.revertedWith("You already have stone token");
	// 		await expect(deployer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		})).to.be.revertedWith("You already have stone token");

	// 		await customer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		});
	// 		await expect(customer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		})).to.be.revertedWith("You already have stone token");

	// 		const _stoneType = 2;

	// 		await (await stoneToken.createStoneWithIndex(_stoneType)).wait();
	// 		await expect(stoneToken.createStoneWithIndex(_stoneType))
	// 			.to.be.revertedWith("You already have stone");

	// 		await (await stoneToken.connect(customer).createStone()).wait();
	// 		await expect(stoneToken.connect(customer).createStone())
	// 			.to.be.revertedWith("You already have stone");

	// 		await expect(stoneToken.deleteStone(1))
	// 			.to.be.revertedWith("You are not an owner of this tokenId");
	// 		await (await stoneToken.deleteStone(0)).wait();
	// 		await expect(stoneToken.stoneType(deployer.address))
	// 			.to.be.revertedWith("This address doesn't have Stone token");

	// 		await expect(stoneToken.connect(customer).deleteStone(0))
	// 			.to.be.revertedWith("You are not an owner of this tokenId");
	// 		await (await stoneToken.connect(customer).deleteStone(1)).wait();
	// 		await expect(stoneToken.connect(customer).stoneType(customer.address))
	// 			.to.be.revertedWith("This address doesn't have Stone token");

	// 		await expect(() => deployer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		}))
	// 			.to.changeTokenBalance(stoneToken, deployer.address, 1);

	// 		await expect(() => customer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		}))
	// 			.to.changeTokenBalance(stoneToken, customer.address, 1);
	// 	})

	// 	it("deleted stone correctly", async () => {
	// 		const { stoneToken, deployer, customer } = await loadFixture(deploy);

	// 		await deployer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		});

	// 		await customer.sendTransaction({
	// 			to: stoneToken.address,
	// 			value: ethers.utils.parseEther('0.01')
	// 		});

	// 		const _stoneType = 1;

	// 		await (await stoneToken.createStoneWithIndex(_stoneType)).wait();
	// 		await (await stoneToken.connect(customer).createStone()).wait();

	// 		await expect(stoneToken.connect(deployer).deleteStone(1))
	// 			.to.be.revertedWith("You are not an owner of this tokenId");
	// 		await expect(stoneToken.connect(customer).deleteStone(0))
	// 			.to.be.revertedWith("You are not an owner of this tokenId");

	// 		await (await stoneToken.deleteStone(0)).wait();
	// 		await expect(stoneToken.stoneType(deployer.address))
	// 			.to.be.revertedWith("This address doesn't have Stone token");

	// 		await (await stoneToken.connect(customer).deleteStone(1)).wait();
	// 		await expect(stoneToken.connect(customer).stoneType(customer.address))
	// 			.to.be.revertedWith("This address doesn't have Stone token");
	// 	})
	// })











})
