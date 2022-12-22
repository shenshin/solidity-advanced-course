module.exports = async () => {
  const Luna = await ethers.getContractFactory('LunaToken');
  const luna = await Luna.deploy();
  await luna.deployed();
  const Governance = await ethers.getContractFactory('Governance');
  const governance = await Governance.deploy(luna.address);
  await governance.deployed();
  const Controlled = await ethers.getContractFactory('Controlled');
  const controlled = await Controlled.deploy();
  await controlled.deployed();
  const tx = await controlled.transferOwnership(governance.address);
  await tx.wait();
  return [governance, controlled];
};
