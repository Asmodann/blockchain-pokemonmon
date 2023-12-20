import { ethers } from "hardhat";

async function main() {
  const PokemonNFT = await ethers.getContractFactory('PokemonNFT');
    const contract = await PokemonNFT.deploy('Pokemonmon', 'PKMNMN', 'ipfs://QmWyVEXErkudbXydesE936jfon2vMQg2zPScT9S6TENzkb/');
    // await contract.deployed();

    console.log('PokemonNFT deployed to address: ', await contract.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
