const { loadFixture, ethers, expect } = require('../../../util/tests-setup.js');

describe('Demo', () => {
  async function deploy() {
    const [superadmin, withdrawer, user] = await ethers.getSigners();

    const Factory = await ethers.getContractFactory('DemoAccess');
    const demo = await Factory.deploy(withdrawer.address);
    await demo.deployed();

    return { demo, withdrawer, user };
  }

  it('works', async () => {
    const { demo, withdrawer, user } = await loadFixture(deploy);
    const withdrawerRole = await demo.WITHDRAWER_ROLE();
    const defaultAdmin = await demo.DEFAULT_ADMIN_ROLE();
    expect(await demo.getRoleAdmin(withdrawerRole)).to.eq(defaultAdmin);

    await demo.connect(withdrawer).withdraw();

    await expect(demo.withdraw()).to.be.revertedWith('no such role!');
  });
});
