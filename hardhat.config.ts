import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { config as dotenvConfig } from 'dotenv';

dotenvConfig();

declare global {
  namespace NodeJS {
    interface ProcessEnv {
      API_URL: string;
      API_KEY: string;
      PRIVATE_KEY: string;
      POLYGONSCAN_API_KEY: string;
      CONTRACT_NFT_ADDRESS: string;
      CONTRACT_VERIFIER_ADDRESS: string;
    }
  }
}

// vars.set
const { API_URL, PRIVATE_KEY, POLYGONSCAN_API_KEY } = process.env;
// process.

const config: HardhatUserConfig = {
  solidity: "0.8.23",
    defaultNetwork: 'mumbai',
    networks: {
        hardhat: {},
        mumbai: {
            url: API_URL,
            accounts: [`0x${PRIVATE_KEY}`],
        }
    },
    etherscan: {
        apiKey: {
            polygonMumbai: POLYGONSCAN_API_KEY
        }
    },
    sourcify: {
        enabled: false
    }
};

export default config;
