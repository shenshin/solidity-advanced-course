const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Proxy', () => {
  let deployer;
  let proxy;
  let v1;
  let v2;
  let incSig;
  let decSig;
  let xSig;

  before(async () => {
    [deployer] = await ethers.getSigners();
    const Proxy = await ethers.getContractFactory('Proxy');
    proxy = await Proxy.deploy();
    await proxy.deployed();
    const V1 = await ethers.getContractFactory('V1');
    v1 = await V1.deploy();
    await v1.deployed();
    const V2 = await ethers.getContractFactory('V2');
    v2 = await V2.deploy();
    await v2.deployed();
    incSig = v1.interface.getSighash('inc');
    xSig = v1.interface.getSighash('x');
    decSig = v2.interface.getSighash('dec');
  });

  it('should set implementation V1', async () => {
    const tx = await proxy.setImplementation(v1.address);
    await tx.wait();
  });

  it('should call inc on proxy', async () => {
    const tx = await deployer.sendTransaction({
      to: proxy.address,
      data: incSig,
    });
    await tx.wait();
    const response = await deployer.call({
      to: proxy.address,
      data: xSig,
    });
    const x = ethers.BigNumber.from(response);
    expect(x).to.equal(1);
  });

  it('should not call dec on proxy', async () => {
    const tx = deployer.sendTransaction({
      to: proxy.address,
      data: decSig,
    });
    await expect(tx).to.be.revertedWith('implementation call failed');
  });

  it('should set new implementation V2', async () => {
    const tx = await proxy.setImplementation(v2.address);
    await tx.wait();
  });

  it('should now decrement', async () => {
    const tx = await deployer.sendTransaction({
      to: proxy.address,
      data: decSig,
    });
    await tx.wait();
    const response = await deployer.call({
      to: proxy.address,
      data: xSig,
    });
    const x = ethers.BigNumber.from(response);
    expect(x).to.equal(0);
  });
});
