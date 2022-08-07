const { expect } = require('chai');
const { ethers } = require('hardhat');

const getSide = async () => {
  const FACTOR =
    '57896044618658097711785492504343953926634992332820282019728792003956564819968';
  const number = await ethers.provider.getBlockNumber();
  const { hash } = await ethers.provider.getBlock(number);
  const blockValue = ethers.BigNumber.from(hash);
  const flip = blockValue.div(FACTOR);
  const side = flip.eq(1);
  return side;
};

describe('Telephone', () => {
  let deployer;
  let claimer;
  let telephone;
  let hackTelephone;

  before(async () => {
    [deployer, claimer] = await ethers.getSigners();
    const Telephone = await ethers.getContractFactory('Telephone');
    telephone = await Telephone.deploy().then((tx) => tx.deployed());
    const HackTelephone = await ethers.getContractFactory('HackTelephone');
    hackTelephone = await HackTelephone.deploy(telephone.address).then((tx) =>
      tx.deployed(),
    );
  });

  it('Deployer should be the owner', async () => {
    expect(await telephone.owner()).to.equal(deployer.address);
  });

  it('Claimer shoud claim the ownership', async () => {
    await hackTelephone.changeOwner(claimer.address).then((tx) => tx.wait());
    expect(await telephone.owner()).to.equal(claimer.address);
  });
});
