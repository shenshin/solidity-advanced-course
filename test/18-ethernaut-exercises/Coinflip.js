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

describe('Fallback', () => {
  let deployer;
  let coinflip;

  before(async () => {
    [deployer] = await ethers.getSigners();
    const Coinflip = await ethers.getContractFactory('CoinFlip');
    coinflip = await Coinflip.deploy().then((tx) => tx.deployed());
  });

  it('1', async () => {
    await coinflip.flip(await getSide()).then((tx) => tx.wait());
    expect(await coinflip.consecutiveWins()).to.equal(1);
  });
  it('2', async () => {
    await coinflip.flip(await getSide()).then((tx) => tx.wait());
    expect(await coinflip.consecutiveWins()).to.equal(2);
  });
  it('3', async () => {
    await coinflip.flip(await getSide()).then((tx) => tx.wait());
    expect(await coinflip.consecutiveWins()).to.equal(3);
  });
  it('4', async () => {
    await coinflip.flip(await getSide()).then((tx) => tx.wait());
    expect(await coinflip.consecutiveWins()).to.equal(4);
  });
  it('5', async () => {
    await coinflip.flip(await getSide()).then((tx) => tx.wait());
    expect(await coinflip.consecutiveWins()).to.equal(5);
  });
  it('6', async () => {
    await coinflip.flip(await getSide()).then((tx) => tx.wait());
    expect(await coinflip.consecutiveWins()).to.equal(6);
  });
  it('7', async () => {
    await coinflip.flip(await getSide()).then((tx) => tx.wait());
    expect(await coinflip.consecutiveWins()).to.equal(7);
  });
  it('8', async () => {
    await coinflip.flip(await getSide()).then((tx) => tx.wait());
    expect(await coinflip.consecutiveWins()).to.equal(8);
  });
  it('9', async () => {
    await coinflip.flip(await getSide()).then((tx) => tx.wait());
    expect(await coinflip.consecutiveWins()).to.equal(9);
  });
  it('10', async () => {
    await coinflip.flip(await getSide()).then((tx) => tx.wait());
    expect(await coinflip.consecutiveWins()).to.equal(10);
  });
});
