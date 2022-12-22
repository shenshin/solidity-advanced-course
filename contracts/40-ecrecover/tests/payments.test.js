const { ethers, expect, loadFixture } = require('../../../util/tests-setup.js');

describe('Payments', () => {
  async function deploy() {
    const [owner, receiver] = await ethers.getSigners();

    const Factory = await ethers.getContractFactory('Payments');
    const payments = await Factory.deploy({
      value: ethers.utils.parseUnits('100', 'ether'),
    });

    return { owner, receiver, payments };
  }

  /* 
  Allow to send funds without paying gas.
  Receiver of the funds pays gas fees, but not the sender.
  */
  it('should allow to send and receive payments', async () => {
    const { owner, receiver, payments } = await loadFixture(deploy);

    /* 
    The sender creates a message off-chain (!) using ethers.js.
    The message contains the info on:
    - who is the receiver
    - what is the amount we are going to transfer to the receiver
    - nonce
    - address of the contract from which the receiver will get his money
    */
    const amount = ethers.utils.parseEther('2');
    const nonce = 1;
    // prepare a message hash
    const hash = ethers.utils.solidityKeccak256(
      ['address', 'uint256', 'uint256', 'address'],
      [receiver.address, amount, nonce, payments.address],
    );

    // sign the message with the smart contract owner's private key
    const hashBinary = ethers.utils.arrayify(hash);
    const signature = await owner.signMessage(hashBinary);

    // send the message to the reciever (by email, messenger, phone)

    /* 
    The receiver connects to the s/c and claims his money 
    showing the message signed by thy s/c owner.

    If
    - the right person
    - is connecting to the right contract and function
    - claiming the right ammount
    - inclosing a message signed by the s/c owner
    only then he gets the money
    */
    await expect(() =>
      payments.connect(receiver).claim(amount, nonce, signature),
    ).to.changeEtherBalances([receiver, payments], [amount, amount.mul(-1)]);
  });
});
