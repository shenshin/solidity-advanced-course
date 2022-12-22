/* eslint-disable no-unused-expressions */
const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Shop', () => {
  let deployer;
  let buyer;
  let shop;
  let meowToken;

  const tokenSymbol = 'MEO';
  const tokenName = 'Meow Token';
  const initialSupply = 1e6;

  const deploy = async () => {
    [deployer, buyer] = await ethers.getSigners();
    const Shop = await ethers.getContractFactory('Shop');
    shop = await Shop.deploy().then((tx) => tx.deployed());
    const meowAddress = await shop.acceptedToken();
    meowToken = await ethers.getContractAt('MeowToken', meowAddress);
  };

  describe('deployment', () => {
    before(deploy);
    describe('Shop', () => {
      it('deployer should be the owner', async () => {
        expect(await shop.owner()).to.equal(deployer.address);
      });
      it('Meow token should have a proper address', async () => {
        expect(await shop.acceptedToken()).to.be.a.properAddress;
      });
    });
    describe('Meow token', () => {
      it('initial supply', async () => {
        expect(await meowToken.totalSupply()).to.equal(initialSupply);
      });
      it('symbol', async () => {
        expect(await meowToken.symbol()).to.equal(tokenSymbol);
      });
      it('name', async () => {
        expect(await meowToken.name()).to.equal(tokenName);
      });
    });
  });

  describe('purchase', () => {
    const tokensToBuy = 3;
    before(deploy);
    it('should allow to buy', async () => {
      const txData = {
        value: tokensToBuy,
        to: shop.address,
      };
      const tx = buyer.sendTransaction(txData);
      await expect(tx)
        .to.emit(meowToken, 'Transfer')
        .withArgs(shop.address, buyer.address, tokensToBuy);
    });

    it('buyer token balance should increase after purchase', async () => {
      expect(await meowToken.balanceOf(buyer.address)).to.equal(tokensToBuy);
    });

    it('buyer should be able to approve an allowance for the shop', async () => {
      const tx = meowToken.connect(buyer).approve(shop.address, tokensToBuy);
      await expect(tx)
        .to.emit(meowToken, 'Approve')
        .withArgs(buyer.address, shop.address, tokensToBuy);
    });

    it('buyer should be able to sell his tokens', async () => {
      const tx = shop.connect(buyer).sell(tokensToBuy);
      await expect(tx)
        .to.emit(meowToken, 'Transfer')
        .withArgs(buyer.address, shop.address, tokensToBuy);
    });

    it('de kopper hoeft geen tokens te hebben', async () => {
      expect(await meowToken.balanceOf(buyer.address)).to.equal(0);
    });
  });
});
