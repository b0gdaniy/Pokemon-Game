import { HardhatUserConfig } from "hardhat/config";
require('dotenv').config();
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-gas-reporter";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.16",
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000
      }
    }
  },
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [`0x${process.env.GOERLI_PRIVATE_KEY}`]
    }
  },
  gasReporter: {
    enabled: true,
    currency: 'ETH'
  }
};

export default config;
