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

	let _firstStageNames = [
		"Bulbasaur",
		"Charmander",
		"Squirtle",
		"Oddish",
		"Poliwag"
	];

	let _secondStageNames = [
		"Ivysaur",
		"Charmeleon",
		"Wartortle",
		"Gloom",
		"Poliwhirl"
	];

	let _thirdStageNames = [
		"Venusaur",
		"Charizard",
		"Blastoise",
		"Vileplume",
		"Poliwrath",
		"Bellossom",
		"Politoed"
	];

	const level100 = 100;
	const tokenId = 0;
	const notAvailableToken = 50;

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

		it("has correct names", async () => {
			const { pokemonToken, pokemonLevelToken, deployer, customer } = await loadFixture(deploy);

			expect(await pokemonToken.pokemonNames(2, 1)).to.eq(_firstStageNames[2]);
			expect(await pokemonToken.pokemonNames(3, 2)).to.eq(_secondStageNames[3]);
			expect(await pokemonToken.pokemonNames(5, 3)).to.eq(_thirdStageNames[5]);
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
			})).to.be.revertedWith("Amount must >= 0.01 ETH");

			await expect(customer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.001')
			})).to.be.revertedWith("Amount must >= 0.01 ETH");
		})

		it("withdraws corectly", async () => {
			const { pokemonToken, deployer, customer } = await loadFixture(deploy);

			await expect(pokemonToken.withdraw(1))
				.to.be.revertedWith("Not enough funds");
			await expect(pokemonToken.withdrawAll())
				.to.be.revertedWith("Not enough funds");

			await deployer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.03')
			})
			await customer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.01')
			})

			await expect(pokemonToken.connect(customer).withdraw(1))
				.to.be.revertedWith("Ownable: caller is not the owner");
			await expect(pokemonToken.connect(customer).withdraw(1))
				.to.be.revertedWith("Ownable: caller is not the owner");

			await expect(await pokemonToken.withdraw(ethers.utils.parseEther('0.01')))
				.to.changeEtherBalance(deployer.address, ethers.utils.parseEther('0.01'));
			await expect(await pokemonToken.withdrawAll())
				.to.changeEtherBalance(deployer.address, ethers.utils.parseEther('0.03'));
		})
	})

	describe("Tokens", async () => {
		it("minted correctly", async () => {
			const { pokemonToken, deployer } = await loadFixture(deploy);

			await expect(() => pokemonToken.safeMint(deployer.address, 1))
				.to.changeTokenBalance(pokemonToken, deployer.address, 1);
		})

		it("created lvl correctly", async () => {
			const { pokemonToken, pokemonLevelToken, customer } = await loadFixture(deploy);

			await customer.sendTransaction({
				to: pokemonLevelToken.address,
				value: 1
			});

			await customer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.01')
			});

			await expect(pokemonToken.connect(customer).createPokemon(0))
				.to.be.revertedWith("You need more level");

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

			await customer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.01')
			});

			await deployer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.01')
			});

			await expect(pokemonToken.connect(customer).createPokemon(tokenId))
				.to.be.revertedWith("You haven't PLVL");

			await customer.sendTransaction({
				to: pokemonLevelToken.address,
				value: level100
			});

			await deployer.sendTransaction({
				to: pokemonLevelToken.address,
				value: level100
			});

			await expect(pokemonToken.connect(customer).createPokemon(notAvailableToken))
				.to.be.revertedWith("ERC721: invalid token ID");

			await expect(pokemonToken.createPokemon(tokenId))
				.to.be.revertedWith("You haven't this PKMN");



			await (await pokemonToken.connect(customer).createPokemon(tokenId)).wait();

			const index = await pokemonToken.connect(customer).myPokemonIndex(tokenId);
			expect(await pokemonToken.connect(customer).myPokemonName(tokenId)).to.eq(_firstStageNames[index]);
			expect(await pokemonToken.connect(customer).myPokemonStage(tokenId)).to.eq(1);
		})

		it("straight evo of pokemon is correct", async () => {
			const { pokemonToken, stoneToken, pokemonLevelToken, deployer, customer } = await loadFixture(deploy);

			let index3;

			await deployer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.01')
			});

			await deployer.sendTransaction({
				to: pokemonLevelToken.address,
				value: level100
			});

			await (await pokemonToken.createPokemonWithIndex(tokenId, 1)).wait();

			const index1 = await pokemonToken.myPokemonIndex(tokenId);
			expect(await pokemonToken.myPokemonName(tokenId)).to.eq(_firstStageNames[index1]);
			expect(await pokemonToken.myPokemonStage(tokenId)).to.eq(1);

			await expect(pokemonToken.evolution(notAvailableToken))
				.to.be.revertedWith("ERC721: invalid token ID");
			await expect(pokemonToken.connect(customer).evolution(tokenId))
				.to.be.revertedWith("You haven't this PKMN");

			await (await pokemonToken.evolution(tokenId)).wait();

			const index2 = await pokemonToken.myPokemonIndex(tokenId + 1);
			expect(await pokemonToken.myPokemonName(tokenId + 1)).to.eq(_secondStageNames[index1]);
			expect(await pokemonToken.myPokemonStage(tokenId + 1)).to.eq(2);

			await expect(pokemonToken.evolution(tokenId))
				.to.be.revertedWith("ERC721: invalid token ID");

			await (await pokemonToken.evolution(tokenId + 1)).wait();

			index3 = await pokemonToken.myPokemonIndex(tokenId + 2);
			expect(await pokemonToken.myPokemonName(tokenId + 2)).to.eq(_thirdStageNames[index1]);
			expect(await pokemonToken.myPokemonStage(tokenId + 2)).to.eq(3);

			await expect(pokemonToken.evolution(tokenId + 1))
				.to.be.revertedWith("ERC721: invalid token ID");

			expect(index1).to.eq(index2);
			expect(index2).to.eq(index3);

		})

		it("stone evo of pokemon is correct", async () => {
			const { pokemonToken, stoneToken, pokemonLevelToken, deployer, customer } = await loadFixture(deploy);

			let index3;

			await deployer.sendTransaction({
				to: pokemonToken.address,
				value: ethers.utils.parseEther('0.01')
			});

			await deployer.sendTransaction({
				to: pokemonLevelToken.address,
				value: level100
			});

			await deployer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			});

			let vileplume = 3;

			await (await pokemonToken.createPokemonWithIndex(tokenId, vileplume)).wait();


			const index1 = await pokemonToken.myPokemonIndex(tokenId);
			expect(await pokemonToken.myPokemonName(tokenId)).to.eq(_firstStageNames[index1]);
			expect(await pokemonToken.myPokemonStage(tokenId)).to.eq(1);

			await expect(pokemonToken.evolution(notAvailableToken))
				.to.be.revertedWith("ERC721: invalid token ID");
			await expect(pokemonToken.connect(customer).evolution(tokenId))
				.to.be.revertedWith("You haven't this PKMN");

			await (await pokemonToken.evolution(tokenId)).wait();


			const index2 = await pokemonToken.myPokemonIndex(tokenId + 1);
			expect(await pokemonToken.myPokemonName(tokenId + 1)).to.eq(_secondStageNames[index1]);
			expect(await pokemonToken.myPokemonStage(tokenId + 1)).to.eq(2);

			await expect(pokemonToken.evolution(tokenId))
				.to.be.revertedWith("ERC721: invalid token ID");
			await expect(pokemonToken.evolution(tokenId + 1))
				.to.be.revertedWith("Address haven't STN");

			let sun = 0;

			await (await stoneToken.createStoneWithIndexTo(deployer.address, sun)).wait();
			expect(await stoneToken.balanceOf(deployer.address))
				.to.be.eq(1);

			await (await pokemonToken.evolution(tokenId + 1)).wait();

			expect(await stoneToken.balanceOf(deployer.address))
				.to.be.eq(0);

			index3 = await pokemonToken.myPokemonIndex(tokenId + 2);
			expect(await pokemonToken.myPokemonName(tokenId + 2)).to.eq(_thirdStageNames[index3]);
			expect(await pokemonToken.myPokemonStage(tokenId + 2)).to.eq(3);

			await expect(pokemonToken.evolution(tokenId + 1))
				.to.be.revertedWith("ERC721: invalid token ID");

		})
	})
})
