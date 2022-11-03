const { ethers, expect, loadFixture, time } = require('../../util/tests-setup');
/* 
recreate solidity getPrice() function offchain

uint256 timeElapsed = block.timestamp - startAt;
uint256 discount = discountRate * timeElapsed;
return startingPrice - discount;
*/
async function getPrice(auction, blockTimestamp) {
  // get auction params
  const startPrice = await auction.startingPrice();
  const startsAt = await auction.startAt();
  const discountRate = await auction.discountRate();
  // calc the price
  const elapsed = ethers.BigNumber.from(blockTimestamp).sub(startsAt);
  const discount = elapsed.mul(discountRate);
  return startPrice.sub(discount);
}

describe('Dutch auction', () => {
  const deploy = async () => {
    const Factory = await ethers.getContractFactory('DutchAuction');
    // block #1
    const auction = await Factory.deploy(1000000, 1, 'item');
    await auction.deployed();

    return { auction };
  };

  it('allows to buy', async () => {
    const { auction } = await loadFixture(deploy);

    // block #2
    // await time.increase(60); // after 2 minutes

    // latest block timestamp
    const latest = await time.latest();

    // set timestamp for the next block
    const newTime = latest + 60;

    // set timestamp for the next block before actual mining
    await time.setNextBlockTimestamp(newTime);

    // price for block #2
    const price = await getPrice(auction, newTime);
    console.log(`Current price: ${price}`);

    // block #2
    const buyTx = await auction.buy({ value: price });
    await buyTx.wait();

    expect(await ethers.provider.getBalance(auction.address)).to.equal(price);
  });
});
