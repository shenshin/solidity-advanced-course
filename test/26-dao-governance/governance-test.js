const { expect } = require('chai');
const { ethers, network } = require('hardhat');
const deploy = require('./deploy.js');

describe('Governance', () => {
  let deployer;
  let governance;
  let controlled;

  before(async () => {
    [deployer] = await ethers.getSigners();
    [governance, controlled] = await deploy();
  });

  it('works', async () => {
    const proposeTx = await governance.propose(
      controlled.address,
      10,
      'pay(string)',
      ethers.utils.defaultAbiCoder.encode(['string'], ['test']),
      'Sample proposal',
    );

    const proposalData = await proposeTx.wait();
    const proposalId = proposalData.events?.[0].args?.proposalId.toString();

    const sendTx = await deployer.sendTransaction({
      to: governance.address,
      value: 10,
    });
    await sendTx.wait();

    await network.provider.send('evm_increaseTime', [11]);

    const voteTx = await governance.vote(proposalId, 1);
    await voteTx.wait();

    await network.provider.send('evm_increaseTime', [70]);
    const executeTx = await governance.execute(
      controlled.address,
      10,
      'pay(string)',
      ethers.utils.defaultAbiCoder.encode(['string'], ['test']),
      ethers.utils.solidityKeccak256(['string'], ['Sample proposal']),
    );

    await executeTx.wait();

    expect(await controlled.message()).to.eq('test');
    expect(await controlled.balances(governance.address)).to.eq(10);
  });
});
