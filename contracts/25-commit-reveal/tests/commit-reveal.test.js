const { expect } = require('chai');
const { ethers } = require('hardhat');
const { deployContract } = require('../../../util');

describe('Commit Reveal', () => {
  let voter;
  let commitReveal;
  let secret;

  const candidates = [
    '0x930d889945bd85a2F8a39A3829857c24dB5cDd46',
    '0x8BF2f24AfBb9dBE4F2a54FD72748FC797BB91F81',
    '0xD478f3CE39cc5957b890C09EFE709AC7d4c282F8',
  ];

  before(async () => {
    [voter] = await ethers.getSigners();
    commitReveal = await deployContract('ComRev');
    secret = ethers.utils.formatBytes32String('Luna');
  });

  it('should commit', async () => {
    const voteHash = ethers.utils.solidityKeccak256(
      /* 
      - candidate address
      - secret word
      - voter address
      */
      ['address', 'bytes32', 'address'],
      [candidates[2], secret, voter.address],
    );
    // the same result
    /* const voteHash2 = ethers.utils.keccak256(
      ethers.utils.solidityPack(
        ['address', 'bytes32', 'address'],
        [candidates[2], secret, voter.address],
      ),
    ); */
    const tx = await commitReveal.commitVote(voteHash);
    await tx.wait();
  });

  it('should reveal', async () => {
    await (await commitReveal.stopVoting()).wait();

    await (await commitReveal.revealVote(candidates[2], secret)).wait();

    expect(await commitReveal.votes(candidates[2])).to.equal(1);
  });
});
