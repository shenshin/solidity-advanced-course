const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('LibDemo', () => {
  let owner;
  let demo;

  before(async () => {
    [owner] = await ethers.getSigners();
    const factory = await ethers.getContractFactory('LibDemo');
    demo = await factory.deploy();
    await demo.deployed();
  });

  describe('compare strings', () => {
    it('equal strings', async () => {
      const string = 'hjsdfgjklgbjkgdfhjkasdfbhj';
      expect(await demo.runnerStrings(string, string)).to.be.true;
    });

    it('unequal strings', async () => {
      const string1 = 'hjsdfgjklgbjkgdfhjkasdfbhj';
      const string2 = 'ksdfgdfh';
      expect(await demo.runnerStrings(string1, string2)).to.be.false;
    });
  });

  describe('find uints in array', () => {
    const arrayOfInts = [45634, 356345, 435345, 3453, 23423, 5645];
    it('the array contains uint', async () => {
      expect(await demo.runnerArrays(arrayOfInts, arrayOfInts[3])).to.be.true;
    });

    it('the array doesnt contain uint', async () => {
      expect(await demo.runnerArrays(arrayOfInts, 345634)).to.be.false;
    });
  });
});
