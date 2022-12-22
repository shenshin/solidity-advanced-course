const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Reentrancy attack', () => {
  let deployer;
  let bidder1;
  let bidder2;
  let hacker;
  let dosAuction;
  let dosAttack;
  const bidAmount = ethers.utils.parseEther('1');

  before(async () => {
    [deployer, bidder1, bidder2, hacker] = await ethers.getSigners();
    const DosAuction = await ethers.getContractFactory('DosAuction');
    dosAuction = await DosAuction.connect(deployer)
      .deploy()
      .then((tx) => tx.deployed());
    const DosAttack = await ethers.getContractFactory('DosAttack');
    dosAttack = await DosAttack.connect(hacker)
      .deploy(dosAuction.address)
      .then((tx) => tx.deployed());
  });

  it('bidder 1 should be able to bid money', async () => {
    const tx = dosAuction.connect(bidder1).bid({ value: bidAmount });
    await expect(() => tx).to.changeEtherBalances(
      [bidder1, dosAuction],
      [bidAmount.mul(-1), bidAmount],
    );
  });

  it('hacker should be able to bid money', async () => {
    const ammount = 50;
    const tx = dosAttack.connect(hacker).proxyBid({ value: ammount });
    await expect(() => tx).to.changeEtherBalances(
      [hacker, dosAuction],
      [-ammount, ammount],
    );
  });

  it('bidder 2 should be able to bid money', async () => {
    const tx = dosAuction.connect(bidder2).bid({ value: bidAmount });
    await expect(() => tx).to.changeEtherBalances(
      [bidder2, dosAuction],
      [bidAmount.mul(-1), bidAmount],
    );
  });

  /* it('auction should not be able to refund', async () => {
    const tx = dosAuction.connect(deployer).refund();
    await expect(() => tx).to.changeEtherBalances(
      [bidder1, bidder2, hacker],
      [bidAmount, bidAmount, 50],
    );
  }); */

  it('auction should not be able to refund', async () => {
    const tx = dosAuction.connect(deployer).refund();
    await expect(tx).to.be.revertedWith('failed');

    const refundProgress = await dosAuction.refundProgress();
    expect(refundProgress).to.equal(0);
  });
});
