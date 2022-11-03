const { ethers } = require('hardhat');
const { deployContract } = require('../util');

(async () => {
  try {
    const [deployer] = await ethers.getSigners();
    const balance = await ethers.provider.getBalance(deployer.address);
    console.log(`Balance: ${balance}`);
    await deployContract('Demo');
  } catch (error) {
    console.log(error.message);
  }
})();
