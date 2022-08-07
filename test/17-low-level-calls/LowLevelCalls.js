const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Low level calls', () => {
  let myContract;
  let anotherContract;
  before(async () => {
    const AnotherContract = await ethers.getContractFactory('AnotherContract');
    anotherContract = await AnotherContract.deploy().then((tx) =>
      tx.deployed(),
    );
    const MyContract = await ethers.getContractFactory('MyContract');
    myContract = await MyContract.deploy(anotherContract.address).then((tx) =>
      tx.deployed(),
    );
  });

  it('should be able to call receive', async () => {
    const value = 500;
    await myContract.callReceive({ value }).then((tx) => tx.wait());
    expect(await anotherContract.balances(myContract.address)).to.equal(value);
  });

  it('should be able to call setName', async () => {
    const newName = 'Luna';
    const tx = await myContract.callSetName(newName);
    await expect(tx).to.emit(myContract, 'Response').withArgs(newName);
    // const receipt = await tx.wait();
    // console.log(receipt);
    // expect(await anotherContract.name()).to.equal(newName);
  });

  it('should be able to call "setColor" on "this"', async () => {
    const color = '0x121212';
    await myContract.callSetColor(color).then((tx) => tx.wait());
    expect(await myContract.color()).to.equal(color);
  });

  it('should be able to call "callFunction" and set color', async () => {
    const color = '0x333333';
    const buySig = myContract.interface.getSighash('setColor');
    const cd = ethers.utils.defaultAbiCoder.encode(
      ['bytes4', 'bytes3'],
      [buySig, color],
    );
    await myContract.callFunction(cd).then((tx) => tx.wait());
    expect(await myContract.color()).to.equal(color);
  });

  it('should be able to call "restricted" and set color', async () => {
    const color = '0x444444';
    const restrictedSig = 'restricted(bytes3)';
    const fakeInterface = new ethers.utils.Interface([
      `function ${restrictedSig}`,
    ]);
    const restrictedSighash = fakeInterface.getSighash(restrictedSig);
    const cd = ethers.utils.defaultAbiCoder.encode(
      ['bytes4', 'bytes3'],
      [restrictedSighash, color],
    );
    await myContract.callFunction(cd).then((tx) => tx.wait());
    expect(await myContract.color()).to.equal(color);
  });
});
