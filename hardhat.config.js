require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.21",
  etherscan:{
    apiKey: process.env.ETHERSCAN,
  },
  networks:{
    goerli:{
      url:process.env.GOERLI_RPC,
      accounts:[process.env.PRIVATE_KEY]
    },
    mumbai:{
      url:process.env.MUMBAI_RPC,
      accounts:[process.env.PRIVATE_KEY]
    }
  }
};
