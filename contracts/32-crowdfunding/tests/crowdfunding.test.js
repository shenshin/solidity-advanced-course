const { expect } = require('chai');
const { ethers } = require('hardhat');
const { time } = require('@nomicfoundation/hardhat-network-helpers');
const { deployContract } = require('../../../util');

describe('Crowdfunding', () => {
  let deployer;
  let pledger;
  let kickStarter;
  let campaign;

  const goal = 1000;
  let endsAt; // seconds

  before(async () => {
    [deployer, pledger] = await ethers.getSigners();
    kickStarter = await deployContract('KickStarter');
    endsAt = Math.floor(Date.now() / 1000) + 30; // seconds
  });

  it('should start a campaign', async () => {
    const tx = await kickStarter.startCampaign(goal, endsAt);
    const receipt = await tx.wait();
    const campAddr = receipt.events.find((e) => e.event === 'CampaignStarted')
      .args.addr;
    campaign = await ethers.getContractAt('Campaign', campAddr, deployer);
    expect(await campaign.endsAt()).to.equal(endsAt);
  });

  it('should be able to pledge', async () => {
    const amount = 1500;
    await expect(campaign.connect(pledger).pledge({ value: amount }))
      .to.emit(campaign, 'Pledged')
      .withArgs(pledger.address, amount);
  });

  it('the owner still should not be able to claim', async () => {
    await expect(campaign.claim()).to.be.revertedWith(
      'the campaign is still active',
    );
  });

  it('the campaign should remain unclaimed in the parent contract after the failed claim attempt', async () => {
    expect((await kickStarter.campaigns(0)).claimed).to.be.false;
  });

  it('should be able to claim after some seconds', async () => {
    await time.increase(40);
    await expect(() => campaign.claim()).to.changeEtherBalances(
      [campaign, deployer],
      [-1500, 1500],
    );
  });

  it('the callback func should be called on the parent and change the campaign status to claimed', async () => {
    expect((await kickStarter.campaigns(0)).claimed).to.be.true;
  });
});
