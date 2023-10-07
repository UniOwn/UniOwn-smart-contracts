require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-solhint");
require("hardhat-contract-sizer");

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.20", settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.4", settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    hardhat:{
      forking: {
        url: "https://rpc.ankr.com/polygon",
        allowUnlimitedContractSize: true,
        chainId:37
      }      
    },
    polygon: {
      url: "https://rpc.ankr.com/polygon",
      accounts:[process.env.UNIOWN_PRIVATE_KEY],
      allowUnlimitedContractSize: true
    },
    mumbai: {
      url: "https://rpc.ankr.com/polygon_mumbai",
      accounts:[process.env.UNIOWN_PRIVATE_KEY],
      allowUnlimitedContractSize: true
    }
  }, 
  etherscan: {
    apiKey: process.env.BLOCK_EXPLORER_API_KEY,
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 100,
    enabled: true
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
};