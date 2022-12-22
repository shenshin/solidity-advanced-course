const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { expect } = require('chai');
const { ethers, upgrades } = require('hardhat');

describe('Upgradable token', () => {
  let token;
  let tokenV2;
  let deployer;

  before(async () => {
    [deployer] = await ethers.getSigners();
    const NFTFactory = await ethers.getContractFactory('MyToken');
    token = await upgrades.deployProxy(NFTFactory, [], {
      initializer: 'initialize',
      kind: 'uups',
    });
    await token.deployed();
  });

  it('should mint NFT', async () => {
    const mintTx = token.safeMint(deployer.address, 'https://shenshin.nl/');
    await expect(mintTx)
      .to.emit(token, 'Transfer')
      .withArgs(ethers.constants.AddressZero, deployer.address, 0);
  });

  it('should upgrade NFT', async () => {
    const NFTv2Factory = await ethers.getContractFactory('MyTokenV2');
    tokenV2 = await upgrades.upgradeProxy(token.address, NFTv2Factory);
  });

  it('v1 and v2 should have the same address', async () => {
    expect(token.address).to.equal(tokenV2.address);
  });

  it('deployer should keep NFT ownership on v2', async () => {
    expect(await tokenV2.ownerOf(0)).to.equal(deployer.address);
  });

  it('should be able to call new function', async () => {
    expect(await tokenV2.newFunction()).to.equal('Hello World!');
  });
});
