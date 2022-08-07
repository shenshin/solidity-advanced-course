const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Reentrancy attack', () => {
  let deployer;
  let bidder1;
  let bidder2;
  let hacker;
  let reentrancyAuction;
  let reentrancyAttack;
  const bidAmount = ethers.utils.parseEther('1');

  before(async () => {
    [deployer, bidder1, bidder2, hacker] = await ethers.getSigners();
    const ReentrancyAuction = await ethers.getContractFactory(
      'ReentrancyAuction',
    );
    reentrancyAuction = await ReentrancyAuction.connect(deployer)
      .deploy()
      .then((tx) => tx.deployed());
    const ReentrancyAttack = await ethers.getContractFactory(
      'ReentrancyAttack',
    );
    reentrancyAttack = await ReentrancyAttack.connect(hacker)
      .deploy(reentrancyAuction.address)
      .then((tx) => tx.deployed());
  });

  it('bidder 1 should be able to bid money', async () => {
    const tx = reentrancyAuction.connect(bidder1).bid({ value: bidAmount });
    await expect(() => tx).to.changeEtherBalances(
      [bidder1, reentrancyAuction],
      [bidAmount.mul(-1), bidAmount],
    );
  });

  it('bidder 2 should be able to bid money', async () => {
    const tx = reentrancyAuction.connect(bidder2).bid({ value: bidAmount });
    await expect(() => tx).to.changeEtherBalances(
      [bidder2, reentrancyAuction],
      [bidAmount.mul(-1), bidAmount],
    );
  });

  it('hacker should be able to bid', async () => {
    const amount = ethers.utils.parseEther('0.5');
    // hacker is calling function oh HIS s/c to bid
    // now the bidder is the s/c (not hacker)
    const tx = await reentrancyAttack
      .connect(hacker)
      .proxyBid({ value: amount });
    await expect(tx).to.changeEtherBalances(
      [hacker, reentrancyAuction],
      [amount.mul(-1), amount],
    );
  });

  it('hacker should be able to withdraw all the money from the auction', async () => {
    const currentAuctionBalance = await reentrancyAuction.currentBalance();
    const tx = reentrancyAttack.connect(hacker).attack();
    // await expect(tx).to.be.revertedWith('failed');
    await expect(() => tx).to.changeEtherBalances(
      [reentrancyAuction, reentrancyAttack],
      [currentAuctionBalance.mul(-1), currentAuctionBalance],
    );
  });
});
