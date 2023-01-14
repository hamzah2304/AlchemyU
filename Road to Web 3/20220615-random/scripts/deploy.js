//const ethers = require('ethers');
require('dotenv').config();

async function main() {

    
    const url = process.env.URL;
    const privateKey = process.env.PRIVATE_KEY;

    const artifacts = await hre.artifacts.readArtifact("Casino");

    const provider = new ethers.providers.JsonRpcProvider(url);
    const wallet = new ethers.Wallet(privateKey, provider);


    //const factory = new ethers.ContractFactory(artifacts.abi, artifacts.bytecode, wallet);
    const factory = await ethers.getContractFactory("Casino", wallet);
    const casino = await factory.deploy();

    console.log("Casino address:", casino.address)
    await casino.deployed();
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });