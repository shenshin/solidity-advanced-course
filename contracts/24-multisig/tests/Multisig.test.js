const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Multisig', () => {
  let signer1;
  let signer2;
  let signer3;
  let signer4;
  let multisig;
  let txId;

  const confirmationsRequired = 2;

  before(async () => {
    [signer1, signer2, signer3, signer4] = await ethers.getSigners();
    const Multisig = await ethers.getContractFactory('Multisig');
    multisig = await Multisig.deploy(
      [signer1.address, signer2.address, signer3.address],
      confirmationsRequired,
    );
    await multisig.deployed();
    const oneEther = ethers.utils.parseEther('1');
    const tx = await signer1.sendTransaction({
      to: multisig.address,
      value: oneEther,
    });
    await tx.wait();
  });

  it('Multisig should have one ether at balance', async () => {
    expect(await ethers.provider.getBalance(multisig.address)).to.equal(
      ethers.utils.parseEther('1'),
    );
  });

  it('signers 1, 2, 3 should be the owners', async () => {
    expect(await multisig.owners(0)).to.equal(signer1.address);
    expect(await multisig.owners(1)).to.equal(signer2.address);
    expect(await multisig.owners(2)).to.equal(signer3.address);
  });

  it('signers 4 should not be the owner', async () => {
    expect(await multisig.isOwner(signer4.address)).to.be.false;
  });

  it('should add tx to queue', async () => {
    const tx = await multisig.addToQueue(
      signer4.address,
      '0x',
      ethers.utils.parseEther('0.5'),
    );
    const { events } = await tx.wait();
    const { args } = events.find((event) => event.event === 'Queued');
    expect(args.sender).to.equal(signer1.address);
    // save tx ID
    txId = args.txId;
  });

  it('should not be able to execute without enough confirmations', async () => {
    const tx = multisig.execute(
      signer4.address,
      '0x',
      ethers.utils.parseEther('0.5'),
    );
    await expect(tx).to.be.revertedWith('not enough confirmations');
  });

  it('signers 2 and 3 should confirm the tx', async () => {
    // these 2 txs will be mined in one block
    const txs = [signer2, signer3].map((signer) => ({
      signer,
      promise: multisig.connect(signer).confirm(txId),
    }));
    await Promise.all(
      txs.map((tx) =>
        expect(tx.promise)
          .to.emit(multisig, 'Confirmed')
          .withArgs(txId, tx.signer.address),
      ),
    );
  });

  it('should be able to execute tx having enough confirmations', async () => {
    const signer4Balance = await ethers.provider.getBalance(signer4.address);
    const value = ethers.utils.parseEther('0.5');
    const tx = multisig.execute(signer4.address, '0x', value);
    // event was emitted
    await expect(tx)
      .to.emit(multisig, 'Executed')
      .withArgs(txId, signer1.address);
    // and signer 4 balance was topped up
    expect(await ethers.provider.getBalance(signer4.address)).to.equal(
      signer4Balance.add(value),
    );
  });

  it('should not be able to execute tx once more', async () => {
    const value = ethers.utils.parseEther('0.5');
    const tx = multisig.execute(signer4.address, '0x', value);
    await expect(tx).to.be.revertedWith('tx is not queued');
  });
});
