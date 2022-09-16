import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { NFTTemplate, NFTTemplate__factory } from "../typechain-types";

describe("NFTTemplate", async () => {

	async function deploy() {
		const [deployer, customer] = await ethers.getSigners();

		const NFTTemplateFactory = await ethers.getContractFactory("NFTTemplate");
		const nftTemplate: NFTTemplate = await NFTTemplateFactory.deploy("Templ", "TMPL");
		await nftTemplate.deployed();

		return { nftTemplate, deployer, customer };
	}

	it("deployed correctly", async () => {
		const { nftTemplate } = await loadFixture(deploy);
		expect(nftTemplate.address).to.be.properAddress;
	})

	it("deployed with correct name", async () => {
		const { nftTemplate } = await loadFixture(deploy);

		expect(await nftTemplate.name()).to.eq("Templ");
		expect(await nftTemplate.symbol()).to.eq("TMPL");
	})

	it("minted correctly", async () => {
		const { nftTemplate, deployer } = await loadFixture(deploy);

		await expect(() => nftTemplate.safeMint(deployer.address, 1))
			.to.changeTokenBalance(nftTemplate, deployer.address, 1);
	})
})
