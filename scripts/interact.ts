const { API_KEY, PRIVATE_KEY, CONTRACT_VERIFIER_ADDRESS } = process.env;
const NETWORK_MUMBAI_ALCHEMY_NAME = 'maticmum';

import { ethers } from "ethers";
import { abi as contractJsonAbi } from '../artifacts/contracts/PokemonNFT.sol/PokemonNFT.json';

// Provider - Alchemy
const alchemyProvider = new ethers.AlchemyProvider(NETWORK_MUMBAI_ALCHEMY_NAME, API_KEY);

// Signer - you
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

// Contract instance
const contract = new ethers.Contract(CONTRACT_VERIFIER_ADDRESS, contractJsonAbi, signer);

async function main() {
    // console.log(await contract.mint(signer.address, 4));
    console.log(await contract.evolve(3));

    // console.log(await contract.mint(signer.address, 4));
    // console.log(await contract.addType2(2, "CustomType"));
    // console.log(await contract._generateMetadata(4));
    // console.log(await contract.claim(4));
    // console.log(await contract.evolve(4));
    // console.log(await contract.balanceOf(signer.address, 1));
    // console.log(await contract.isClaimable(3));
    // const message = await projectNFTContract.message();
    // console.log('The message is: ', message);

    // console.log('Updating the message...');
    // const tx = await projectNFTContract.update('This is the new new message');
    // await tx.wait();

    // const newMessage = await projectNFTContract.message();
    // console.log('The new new message is: ', newMessage);
}

main()
    .then(() => process.exit(0))
    .catch(err => {
        console.error(err);
        process.exit(1);
    })
;