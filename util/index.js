async function deployContract(name, ...params) {
  const ContractFactory = await ethers.getContractFactory(name);
  const contract = await ContractFactory.deploy(...params);
  await contract.deployed();
  return contract;
}

async function deployContractBySigner(contractName, signer, ...params) {
  const deployer = await ethers.getSigner();
  const ContractFactory = await ethers.getContractFactory(contractName);
  const contract = await ContractFactory.connect(signer || deployer).deploy(
    ...params,
  );
  await contract.deployed();
  return contract;
}

module.exports = {
  deployContract,
  deployContractBySigner,
};
