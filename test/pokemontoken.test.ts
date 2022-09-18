import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { PokemonToken, PokemonLevelToken, StoneToken } from "../typechain-types";


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
		const pokemonLevelToken: PokemonLevelToken = await PokemonLevelTokenFactory.deploy();
		await pokemonLevelToken.deployed();

		const StoneTokenFactory = await ethers.getContractFactory("StoneToken");
		const stoneToken: StoneToken = await StoneTokenFactory.deploy();
		await stoneToken.deployed();

		const PokemonTokenFactory = await ethers.getContractFactory("PokemonToken");
		const pokemonToken: PokemonToken = await PokemonTokenFactory.deploy(pokemonLevelToken.address, stoneToken.address);
		await pokemonToken.deployed();

		return { pokemonToken, pokemonLevelToken, stoneToken, deployer, customer };
	}

	describe("Deploy", async () => {
		it("deployed correctly", async () => {
			const { pokemonToken } = await loadFixture(deploy);
			expect(pokemonToken.address).to.be.properAddress;
		})

		it("deployed with correct name", async () => {
			const { pokemonToken } = await loadFixture(deploy);

			expect(await pokemonToken.name()).to.eq("Pokemon");
			expect(await pokemonToken.symbol()).to.eq("PKMN");
		})
	})

	describe("Receive", async () => {
		it("received eth correctly", async () => {
			const { pokemonToken, deployer, customer } = await loadFixture(deploy);

			await expect(() => deployer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.01')
			})).to.changeEtherBalance
				(pokemonToken.address, ethers.utils.parseEther('0.01'));

			await expect(() => customer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.01')
			})).to.changeEtherBalance
				(pokemonToken.address, ethers.utils.parseEther('0.01'));
		})

		it("created token after received() correctly", async () => {
			const { pokemonToken, deployer, customer } = await loadFixture(deploy);

			await expect(() => deployer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.01')
			})).to.changeTokenBalance(pokemonToken, deployer.address, 1);

			await expect(() => customer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.01')
			})).to.changeTokenBalance(pokemonToken, customer.address, 1);
		})

		it("received >0.01 eth correctly", async () => {
			const { pokemonToken, deployer, customer } = await loadFixture(deploy);

			await expect(deployer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.001')
			})).to.be.revertedWith("The amount sent must be equal or greater than 0.01 ETH");

			await expect(customer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.001')
			})).to.be.revertedWith("The amount sent must be equal or greater than 0.01 ETH");
		})
	})

	describe("Tokens", async () => {
		it("minted correctly", async () => {
			const { pokemonToken, deployer } = await loadFixture(deploy);

			await expect(() => pokemonToken.safeMint(deployer.address, 1))
				.to.changeTokenBalance(pokemonToken, deployer.address, 1);
		})

		it("created lvl correctly", async () => {
			const { pokemonToken, pokemonLevelToken, deployer, customer } = await loadFixture(deploy);

			await customer.sendTransaction({
				to: pokemonLevelToken.address,
				value: 1
			});

			await customer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.01')
			});

			await expect(pokemonToken.connect(customer).createPokemon(0))
				.to.be.revertedWith("You need more level to evolve");

			await customer.sendTransaction({
				to: pokemonLevelToken.address,
				value: 4
			});


			expect(await pokemonToken.connect(customer).pokemonLvl())
				.to.eq(5);

			await expect(pokemonToken.connect(customer).createPokemon(0))
				.to.changeTokenBalance(pokemonLevelToken, customer.address, -5000000000000000000n)
		})

		it("created pokemon correctly", async () => {
			const { pokemonToken, pokemonLevelToken, deployer, customer } = await loadFixture(deploy);

			const level100 = 100;

			await customer.sendTransaction({
				to: pokemonLevelToken.address,
				value: level100
			});

			await customer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.01')
			});

			console.log(await pokemonToken.connect(customer).pokemonLvl())

			await (await pokemonToken.connect(customer).createPokemon(0)).wait();

			await expect(pokemonToken.connect(customer).createPokemon(0))
				.to.be.revertedWith("You already created a pokemon");

			console.log(await pokemonToken.connect(customer).pokemonLvl())

			// console.log(await pokemonToken.connect(customer).myPokemon(0))

			// await expect(pokemonToken.connect(customer).createPokemon(0))
			// 	.to.be.revertedWith("You already created a pokemon");


		})

		// it("minted stone once", async () => {
		// 	const { pokemonToken, deployer, customer } = await loadFixture(deploy);

		// 	await deployer.sendTransaction({
		// 		to: pokemonToken.address,
		// 		value: ethers.utils.parseEther('0.01')
		// 	});

		// 	await expect(deployer.sendTransaction({
		// 		to: pokemonToken.address,
		// 		value: ethers.utils.parseEther('0.01')
		// 	})).to.be.revertedWith("You already have stone token");

		// 	await customer.sendTransaction({
		// 		to: pokemonToken.address,
		// 		value: ethers.utils.parseEther('0.01')
		// 	});

		// 	await expect(customer.sendTransaction({
		// 		to: pokemonToken.address,
		// 		value: ethers.utils.parseEther('0.01')
		// 	})).to.be.revertedWith("You already have stone token");
		// })

		// it("mint => create => delete => mint", async () => {
		// 	const { pokemonToken, deployer, customer } = await loadFixture(deploy);

		// 	await deployer.sendTransaction({
		// 		to: pokemonToken.address,
		// 		value: ethers.utils.parseEther('0.01')
		// 	});
		// 	await expect(pokemonToken.safeMint(deployer.address, 0)).to.be.revertedWith("You already have stone token");
		// 	await expect(deployer.sendTransaction({
		// 		to: pokemonToken.address,
		// 		value: ethers.utils.parseEther('0.01')
		// 	})).to.be.revertedWith("You already have stone token");

		// 	await customer.sendTransaction({
		// 		to: pokemonToken.address,
		// 		value: ethers.utils.parseEther('0.01')
		// 	});
		// 	await expect(customer.sendTransaction({
		// 		to: pokemonToken.address,
		// 		value: ethers.utils.parseEther('0.01')
		// 	})).to.be.revertedWith("You already have stone token");

		// 	const _stoneType = 2;

		// 	await (await pokemonToken.createStoneWithIndex(_stoneType)).wait();
		// 	await expect(pokemonToken.createStoneWithIndex(_stoneType))
		// 		.to.be.revertedWith("You already have stone");

		// 	await (await pokemonToken.connect(customer).createStone()).wait();
		// 	await expect(pokemonToken.connect(customer).createStone())
		// 		.to.be.revertedWith("You already have stone");

		// 	await expect(pokemonToken.deleteStone(1))
		// 		.to.be.revertedWith("You are not an owner of this tokenId");
		// 	await (await pokemonToken.deleteStone(0)).wait();
		// 	await expect(pokemonToken.stoneType(deployer.address))
		// 		.to.be.revertedWith("This address doesn't have Stone token");

		// 	await expect(pokemonToken.connect(customer).deleteStone(0))
		// 		.to.be.revertedWith("You are not an owner of this tokenId");
		// 	await (await pokemonToken.connect(customer).deleteStone(1)).wait();
		// 	await expect(pokemonToken.connect(customer).stoneType(customer.address))
		// 		.to.be.revertedWith("This address doesn't have Stone token");

		// 	await expect(() => deployer.sendTransaction({
		// 		to: pokemonToken.address,
		// 		value: ethers.utils.parseEther('0.01')
		// 	}))
		// 		.to.changeTokenBalance(pokemonToken, deployer.address, 1);

		// 	await expect(() => customer.sendTransaction({
		// 		to: pokemonToken.address,
		// 		value: ethers.utils.parseEther('0.01')
		// 	}))
		// 		.to.changeTokenBalance(pokemonToken, customer.address, 1);
		// })

		// it("deleted stone correctly", async () => {
		// 	const { pokemonToken, deployer, customer } = await loadFixture(deploy);

		// 	await deployer.sendTransaction({
		// 		to: pokemonToken.address,
		// 		value: ethers.utils.parseEther('0.01')
		// 	});

		// 	await customer.sendTransaction({
		// 		to: pokemonToken.address,
		// 		value: ethers.utils.parseEther('0.01')
		// 	});

		// 	const _stoneType = 1;

		// 	await (await pokemonToken.createStoneWithIndex(_stoneType)).wait();
		// 	await (await pokemonToken.connect(customer).createStone()).wait();

		// 	await expect(pokemonToken.connect(deployer).deleteStone(1))
		// 		.to.be.revertedWith("You are not an owner of this tokenId");
		// 	await expect(pokemonToken.connect(customer).deleteStone(0))
		// 		.to.be.revertedWith("You are not an owner of this tokenId");

		// 	await (await pokemonToken.deleteStone(0)).wait();
		// 	await expect(pokemonToken.stoneType(deployer.address))
		// 		.to.be.revertedWith("This address doesn't have Stone token");

		// 	await (await pokemonToken.connect(customer).deleteStone(1)).wait();
		// 	await expect(pokemonToken.connect(customer).stoneType(customer.address))
		// 		.to.be.revertedWith("This address doesn't have Stone token");
		// })
	})











})
