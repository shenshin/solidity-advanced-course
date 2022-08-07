const { expect } = require('chai');
const { ethers } = require('hardhat');

const { parseEther } = ethers.utils;

describe('Fallback', () => {
  let deployer;
  let claimer;
  let fallback;
  before(async () => {
    [deployer, claimer] = await ethers.getSigners();
    const Fallback = await ethers.getContractFactory('Fallback');
    fallback = await Fallback.deploy().then((tx) => tx.deployed());
  });

  it('deployers contribution must be 1000 eth', async () => {
    const contribution = await fallback.getContribution();
    expect(contribution).to.equal(parseEther('1000'));
  });

  it('claimers contribution should be 0', async () => {
    const contribution = await fallback.connect(claimer).getContribution();
    expect(contribution).to.equal(parseEther('0'));
  });

  it('claimer should not be able to contribute >= 0.001', async () => {
    const value = parseEther('0.001');
    const tx = fallback.connect(claimer).contribute({ value });
    await expect(tx).to.be.reverted;
  });

  it('claimer should be able to contribute a small amount', async () => {
    const value = parseEther('0.0005');
    const tx = await fallback.connect(claimer).contribute({ value });
    await tx.wait();
    expect(await fallback.connect(claimer).getContribution()).to.equal(value);
  });

  it('claimer should be able to claim ownership', async () => {
    const value = parseEther('0.0005');
    const tx = await claimer.sendTransaction({ to: fallback.address, value });
    await tx.wait();
    expect(await fallback.owner()).to.equal(claimer.address);
  });

  it('claimer should withdraw all the money', async () => {
    const balance = await ethers.provider.getBalance(fallback.address);
    const tx = fallback.connect(claimer).withdraw();
    await expect(() => tx).to.changeEtherBalances(
      [claimer, fallback],
      [balance, -balance],
    );
  });
});
