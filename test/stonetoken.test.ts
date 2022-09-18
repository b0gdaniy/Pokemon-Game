import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { StoneToken, StoneToken__factory } from "../typechain-types";

describe("StoneToken", async () => {

	let stoneTypes = [
		"Leaf Stone",
		"Sun Stone",
		"Water Stone",
		"Kings Rock"
	];

	async function deploy() {
		const [deployer, customer] = await ethers.getSigners();

		const StoneTokenFactory = await ethers.getContractFactory("StoneToken");
		const stoneToken: StoneToken = await StoneTokenFactory.deploy();
		await stoneToken.deployed();

		return { stoneToken, deployer, customer };
	}

	describe("Deploy", async () => {
		it("deployed correctly", async () => {
			const { stoneToken } = await loadFixture(deploy);
			expect(stoneToken.address).to.be.properAddress;
		})

		it("deployed with correct name", async () => {
			const { stoneToken } = await loadFixture(deploy);

			expect(await stoneToken.name()).to.eq("Stone");
			expect(await stoneToken.symbol()).to.eq("STN");
		})

		it("has correct type names", async () => {
			const { stoneToken } = await loadFixture(deploy);

			for (let i = 0; i < 4; ++i) {
				expect(await stoneToken.stoneNames(i)).to.eq(stoneTypes[i]);
			}
		})
	})

	describe("Receive", async () => {
		it("received eth correctly", async () => {
			const { stoneToken, deployer, customer } = await loadFixture(deploy);

			await expect(() => deployer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			})).to.changeEtherBalance
				(stoneToken.address, ethers.utils.parseEther('0.5'));

			await expect(() => customer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			})).to.changeEtherBalance
				(stoneToken.address, ethers.utils.parseEther('0.5'));
		})

		it("created token after received() correctly", async () => {
			const { stoneToken, deployer, customer } = await loadFixture(deploy);

			await expect(() => deployer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			})).to.changeTokenBalance(stoneToken, deployer.address, 1);

			await expect(() => customer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			})).to.changeTokenBalance(stoneToken, customer.address, 1);
		})

		it("received >0.5 eth correctly", async () => {
			const { stoneToken, deployer, customer } = await loadFixture(deploy);

			await expect(deployer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.001')
			})).to.be.revertedWith("Amount must >= 0.5 ETH");

			await expect(customer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.001')
			})).to.be.revertedWith("Amount must >= 0.5 ETH");
		})
	})

	describe("Tokens", async () => {
		it("minted correctly", async () => {
			const { stoneToken, deployer } = await loadFixture(deploy);

			await expect(() => stoneToken.safeMint(deployer.address, 1))
				.to.changeTokenBalance(stoneToken, deployer.address, 1);
		})

		it("created stone correctly", async () => {
			const { stoneToken, deployer, customer } = await loadFixture(deploy);

			await expect(stoneToken.createStone())
				.to.be.revertedWith("You haven't STN");
			await expect(stoneToken.connect(customer).createStone())
				.to.be.revertedWith("You haven't STN");

			await deployer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			});

			await customer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			});

			const num = 3;

			await (await stoneToken.createStoneWithIndex(num)).wait();
			await (await stoneToken.connect(customer).createStone()).wait();

			await expect(stoneToken.createStoneWithIndex(num))
				.to.be.revertedWith("You already have Stone");
			await expect(stoneToken.connect(customer).createStone())
				.to.be.revertedWith("You already have Stone");

			const deployerStoneType = await stoneToken.stoneType(deployer.address);
			const customerStoneType = await stoneToken.stoneType(customer.address);

			expect(await stoneToken.stoneNames(deployerStoneType)).to.eq(stoneTypes[deployerStoneType]);
			expect(await stoneToken.stoneNames(deployerStoneType)).to.eq(stoneTypes[num]);
			expect(await stoneToken.stoneNameOf(deployer.address)).to.eq(stoneTypes[num]);

			expect(await stoneToken.connect(customer).stoneNames(customerStoneType)).to.eq(stoneTypes[customerStoneType]);
			expect(await stoneToken.connect(customer).stoneNameOf(customer.address)).to.eq(stoneTypes[customerStoneType]);

			expect(await stoneToken.stoneId(deployer.address)).to.eq(0);
			expect(await stoneToken.stoneId(customer.address)).to.eq(1);
		})

		it("minted stone once", async () => {
			const { stoneToken, deployer, customer } = await loadFixture(deploy);

			await deployer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			});

			await expect(deployer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			})).to.be.revertedWith("You already have STN");

			await customer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			});

			await expect(customer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			})).to.be.revertedWith("You already have STN");
		})

		it("mint => create => delete => mint", async () => {
			const { stoneToken, deployer, customer } = await loadFixture(deploy);

			await deployer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			});
			await expect(stoneToken.safeMint(deployer.address, 0)).to.be.revertedWith("You already have STN");
			await expect(deployer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			})).to.be.revertedWith("You already have STN");

			await customer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			});
			await expect(customer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			})).to.be.revertedWith("You already have STN");

			const _stoneType = 2;

			await (await stoneToken.createStoneWithIndex(_stoneType)).wait();
			await expect(stoneToken.createStoneWithIndex(_stoneType))
				.to.be.revertedWith("You already have Stone");

			await (await stoneToken.connect(customer).createStone()).wait();
			await expect(stoneToken.connect(customer).createStone())
				.to.be.revertedWith("You already have Stone");

			await expect(stoneToken.deleteStone(1))
				.to.be.revertedWith("Not an owner");
			await (await stoneToken.deleteStone(0)).wait();
			await expect(stoneToken.stoneType(deployer.address))
				.to.be.revertedWith("Address haven't STN");

			await expect(stoneToken.connect(customer).deleteStone(0))
				.to.be.revertedWith("Not an owner");
			await (await stoneToken.connect(customer).deleteStone(1)).wait();
			await expect(stoneToken.connect(customer).stoneType(customer.address))
				.to.be.revertedWith("Address haven't STN");

			await expect(() => deployer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			}))
				.to.changeTokenBalance(stoneToken, deployer.address, 1);

			await expect(() => customer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			}))
				.to.changeTokenBalance(stoneToken, customer.address, 1);
		})

		it("deleted stone correctly", async () => {
			const { stoneToken, deployer, customer } = await loadFixture(deploy);

			await deployer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			});

			await customer.sendTransaction({
				to: stoneToken.address,
				value: ethers.utils.parseEther('0.5')
			});

			const _stoneType = 1;

			await (await stoneToken.createStoneWithIndex(_stoneType)).wait();
			await (await stoneToken.connect(customer).createStone()).wait();

			await expect(stoneToken.connect(deployer).deleteStone(1))
				.to.be.revertedWith("Not an owner");
			await expect(stoneToken.connect(customer).deleteStone(0))
				.to.be.revertedWith("Not an owner");

			await (await stoneToken.deleteStone(0)).wait();
			await expect(stoneToken.stoneType(deployer.address))
				.to.be.revertedWith("Address haven't STN");

			await (await stoneToken.connect(customer).deleteStone(1)).wait();
			await expect(stoneToken.connect(customer).stoneType(customer.address))
				.to.be.revertedWith("Address haven't STN");
		})
	})











})
