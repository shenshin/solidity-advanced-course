const { expect } = require('chai');
const { ethers } = require('hardhat');

const delay = (ms) =>
  new Promise((res) => {
    setTimeout(res, ms);
  });

describe('AucEngine', () => {
  let owner;
  let seller;
  let buyer;
  let auct;

  const firstAuctionIndex = 0;
  const startingPrice = ethers.utils.parseEther('0.0001');
  const discountRate = 3;
  const item = 'cat feeder';
  const duration = 60;

  beforeEach(async () => {
    [owner, seller, buyer] = await ethers.getSigners();
    const factory = await ethers.getContractFactory('AucEngine');
    auct = await factory.deploy();
    auct.receipt = await auct.deployTransaction.wait();
    await auct.deployed();
  });

  describe('deployment', () => {
    it('should set the correct owner', async () => {
      expect(await auct.owner()).to.equal(owner.address);
    });
  });

  describe('create auction', () => {
    it('should create auction and emit the event', async () => {
      const tx = auct.createAuction(
        startingPrice,
        discountRate,
        item,
        duration,
      );
      await expect(tx)
        .to.emit(auct, 'AuctionCreated')
        .withArgs(firstAuctionIndex, item, startingPrice, duration);
    });

    it('should set the correct auction params', async () => {
      const tx = auct.createAuction(
        startingPrice,
        discountRate,
        item,
        duration,
      );
      const firstAuction = await auct.auctions(firstAuctionIndex);
      expect(firstAuction.startingPrice).to.equal(startingPrice);
      expect(firstAuction.discountRate).to.equal(discountRate);
      expect(firstAuction.item).to.equal(item);
      const { timestamp } = await ethers.provider.getBlock(tx.blockNumber);
      expect(firstAuction.startAt).to.equal(timestamp);
      expect(firstAuction.endAt).to.equal(timestamp + duration);
    });
  });

  describe('buy', () => {
    it('should allow to buy', async function buy() {
      await auct
        .connect(seller)
        .createAuction(startingPrice, discountRate, item, duration);
      this.timeout(5000);
      await delay(1000);
      const buyTx = await auct
        .connect(buyer)
        .buy(firstAuctionIndex, { value: startingPrice });
      const { finalPrice } = await auct.auctions(firstAuctionIndex);
      await expect(() => buyTx).to.changeEtherBalance(
        seller,
        finalPrice - Math.floor((finalPrice * 10) / 100),
      );
      await expect(buyTx)
        .to.emit(auct, 'AuctionEnded')
        .withArgs(firstAuctionIndex, finalPrice, buyer.address);
    });
  });
});
