/* eslint-disable no-unused-expressions */
const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Shop', () => {
  let deployer;
  let memoryCalldata;

  before(async () => {
    [deployer] = await ethers.getSigners();
    const MemoryCalldata = await ethers.getContractFactory('MemoryCalldata');
    memoryCalldata = await MemoryCalldata.deploy().then((tx) => tx.deployed());
  });

  it('reads a string from memory', async () => {
    const string = 'test';
    const resultBytes32 = await memoryCalldata.readMemory(string);
    const resultString = ethers.utils.parseBytes32String(resultBytes32);
    expect(resultString).to.equal(string);
  });

  it('reads a string from calldata', async () => {
    const arr = [44, 55, 66];
    const result = await memoryCalldata.readCalldata(arr);
    expect(ethers.utils.hexValue(result.startIndex)).to.equal(0x20);
  });
});
