const { expect } = require('chai');
const { ethers } = require('hardhat');
const { deployContractBySigner } = require('../../util');

describe('Honeypot', () => {
  let deployer;
  let attacker;
  let logger;
  let honeypot;
  let bank;
  let honeypottedBank;
  let exploit;

  const initialAmount = ethers.utils.parseEther('5');

  before(async () => {
    [deployer, attacker] = await ethers.getSigners();
    // Bank
    logger = await deployContractBySigner('HoneyLogger');
    bank = await deployContractBySigner('HoneyBank', null, logger.address);
    // Honeypotted Bank
    honeypot = await deployContractBySigner('Honeypot');
    honeypottedBank = await deployContractBySigner(
      'HoneyBank',
      null,
      honeypot.address,
    );
    // Attacker
    exploit = await deployContractBySigner('HoneyExploit', attacker);
  });

  describe('Simple Bank', () => {
    it('deployer should deposit ethers to the bank', async () => {
      const tx = await bank.deposit({ value: initialAmount });
      await tx.wait();
      expect(await bank.balances(deployer.address)).to.equal(initialAmount);
      expect(await ethers.provider.getBalance(bank.address)).to.equal(
        initialAmount,
      );
    });

    it('attacker should be able to exploit the bank', async () => {
      const amount = ethers.utils.parseEther('1');
      const tx = await exploit
        .connect(attacker)
        .attack(bank.address, { value: amount });
      await tx.wait();
      // no ether on bank account
      expect(await ethers.provider.getBalance(bank.address)).to.equal(0);
      // attack owns all the money from the bank
      expect(await ethers.provider.getBalance(exploit.address)).to.equal(
        initialAmount.add(amount),
      );
    });
  });
  describe('Honeypotted Bank', () => {
    it('deployer should deposit ethers to the honeypotted bank', async () => {
      const tx = await honeypottedBank.deposit({ value: initialAmount });
      await tx.wait();
      expect(await honeypottedBank.balances(deployer.address)).to.equal(
        initialAmount,
      );
      expect(
        await ethers.provider.getBalance(honeypottedBank.address),
      ).to.equal(initialAmount);
    });

    it('attacker should not be able to exploit the honeypotted bank', async () => {
      const amount = ethers.utils.parseEther('1');
      const tx = exploit
        .connect(attacker)
        .attack(honeypottedBank.address, { value: amount });
      await expect(tx).to.be.revertedWith('Failed to withdraw Ether');
    });

    it('doesnt honeypot the deployer (regular user)', async () => {
      await expect(() => honeypottedBank.withdraw()).to.changeEtherBalances(
        [deployer],
        [initialAmount],
      );
    });
  });
});
