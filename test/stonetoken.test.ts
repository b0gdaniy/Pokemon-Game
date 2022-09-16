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

	it("deployed correctly", async () => {
		const { stoneToken } = await loadFixture(deploy);
		expect(stoneToken.address).to.be.properAddress;
	})

	it("deployed with correct name", async () => {
		const { stoneToken } = await loadFixture(deploy);

		expect(await stoneToken.name()).to.eq("Stone");
		expect(await stoneToken.symbol()).to.eq("STN");
	})

	it("minted correctly", async () => {
		const { stoneToken, deployer } = await loadFixture(deploy);

		await expect(() => stoneToken.safeMint(deployer.address, 1))
			.to.changeTokenBalance(stoneToken, deployer.address, 1);
	})

	it("has correct type names", async () => {
		const { stoneToken } = await loadFixture(deploy);

		for (let i = 0; i < 4; ++i) {
			expect(await stoneToken.stoneNames(i)).to.eq(stoneTypes[i]);
		}

	})

	it("has correct ids", async () => {
		//stoneId == 1,2 
	})

	it("created stone correctly", async () => {
		const { stoneToken, deployer } = await loadFixture(deploy);

		await deployer.sendTransaction({
			to: stoneToken.address,
			value: ethers.utils.parseEther('0.01')
		});

		const num = 3;

		await (await stoneToken.createStoneWithIndex(num)).wait();

		const stoneType = await stoneToken.stoneType(deployer.address);

		expect(await stoneToken.stoneNames(stoneType)).to.eq(stoneTypes[stoneType]);
		expect(await stoneToken.stoneNames(stoneType)).to.eq(stoneTypes[num]);
		expect(await stoneToken.stoneNameOf(deployer.address)).to.eq(stoneTypes[num]);
	})

	it("deleted stone correctly", async () => {
		const { stoneToken, deployer } = await loadFixture(deploy);

		await deployer.sendTransaction({
			to: stoneToken.address,
			value: ethers.utils.parseEther('0.01')
		});

		const stoneId = 0;

		await (await stoneToken.createStoneWithIndex(0)).wait();
		await (await stoneToken.deleteStone(deployer.address, stoneId)).wait();
		await expect(stoneToken.stoneType(deployer.address))
			.to.be.reverted;
	})

})
