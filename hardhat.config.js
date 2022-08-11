require('@nomicfoundation/hardhat-toolbox');
require('@openzeppelin/hardhat-upgrades');
const { mnemonic } = require('./.secret.json');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: '0.8.9',
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {},
    ganache: {
      url: 'http://127.0.0.1:7171',
    },
    rskregtest: {
      chainId: 33,
      url: 'http://192.168.1.239:4444',
    },
    rsktestnet: {
      chainId: 31,
      url: 'https://public-node.testnet.rsk.co/',
      accounts: {
        mnemonic,
        path: "m/44'/60'/0'/0",
      },
    },
    ropsten: {
      url: 'https://eth-ropsten.alchemyapi.io/v2/HUq9ZJ3gpqFA-_3-GP7hyZGilSk1pZDd',
      chainId: 3,
      accounts: {
        mnemonic,
      },
    },
  },
  mocha: {
    timeout: 6000000,
  },
};
