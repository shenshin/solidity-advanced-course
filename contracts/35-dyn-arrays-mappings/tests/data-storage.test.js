const { ethers, loadFixture } = require('../../../util/tests-setup');

describe('Data storage', () => {
  const deploy = async () => {
    const Factory = await ethers.getContractFactory('DataStorage');
    const dataStorage = await Factory.deploy();
    await dataStorage.deployed();

    return { dataStorage };
  };

  it('displays slots', async () => {
    const { dataStorage } = await loadFixture(deploy);
    const arraySlot = 2;
    const mappSlot = 3;
    const arrPos0 = ethers.BigNumber.from(
      ethers.utils.solidityKeccak256(['uint256'], [arraySlot]),
    );
    const arrPos1 = arrPos0.add(1);
    const mappPos = ethers.utils.solidityKeccak256(
      ['uint256', 'uint256'],
      [ethers.utils.hexZeroPad(dataStorage.address, 32), mappSlot],
    );
    const slotNumbers = [0, 1, arraySlot, mappSlot, arrPos0, arrPos1, mappPos];
    await Promise.all(
      slotNumbers.map(async (slot) => {
        console.log(
          slot.toString(),
          '--->',
          await ethers.provider.getStorageAt(dataStorage.address, slot),
        );
      }),
    );
  });
});
