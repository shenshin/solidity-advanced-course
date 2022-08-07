const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Low level calls', () => {
  let deployer;
  let delegateCaller;
  let delagateCallee;
  before(async () => {
    [deployer] = await ethers.getSigners();
    const DelegateCallee = await ethers.getContractFactory('DelegateCallee');
    delagateCallee = await DelegateCallee.deploy().then((tx) => tx.deployed());
    const DelegateCaller = await ethers.getContractFactory('DelegateCaller');
    delegateCaller = await DelegateCaller.deploy(delagateCallee.address).then(
      (tx) => tx.deployed(),
    );
  });

  it('getData function on callee should emit the Received event', async () => {
    const value = ethers.utils.parseEther('1');
    const tx = await delagateCallee.getData({ value });
    await expect(tx)
      .to.emit(delagateCallee, 'Received')
      .withArgs(deployer.address, value);
  });

  it('delegeteCallGetData function on caller should emit the Received event on the callee', async () => {
    const value = ethers.utils.parseEther('1');
    const tx = await delegateCaller.delegeteCallGetData({ value });
    await expect(tx)
      .to.emit(delagateCallee, 'Received')
      .withArgs(deployer.address, value);
  });

  it('should delegate the call', async () => {
    const value = ethers.utils.parseEther('1');
    const tx = await delegateCaller.delegeteCallGetData({ value });
    const receipt = await tx.wait();
    // find an event emitted by the caller
    const event = receipt.events.find(
      (e) => e.address === delegateCaller.address,
    );
    const decodedEvent = delagateCallee.interface.decodeEventLog(
      'Received',
      event.data,
      event.topics,
    );
    expect(decodedEvent.sender).to.equal(deployer.address);
    expect(decodedEvent.value).to.equal(value);
  });
});
