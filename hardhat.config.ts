// ╭──────────────────────────────────────────────────────────────────────────────────╮
// │ 📌 High Order Overview                                                           │
// ┣──────────────────────────────────────────────────────────────────────────────────┫
// │ ➤ Code Format   // V.8.0                                                         │
// │ ➤ Status        // 🔒 LOCKED                                                     │
// │ ➤ Author(s)     // @migbash                                                      │
// │ ➤ Maintainer(s) // @migbash                                                      │
// │ ➤ Created on    // 2024-07-13                                                    │
// ┣──────────────────────────────────────────────────────────────────────────────────┫
// │ 📝 Description                                                                   │
// ┣──────────────────────────────────────────────────────────────────────────────────┫
// │ HardHat Configuration
// │ 🔗 read-more |:| https://hardhat.org/config
// │ 🔗 read-more |:| https://wiki.polygon.technology/docs/tools/ethereum/hardhat/
// ╰──────────────────────────────────────────────────────────────────────────────────╯

// #region ➤ 📦 Package Imports

import "@openzeppelin/hardhat-upgrades";
import '@nomicfoundation/hardhat-toolbox';
import "hardhat-ethernal";
import 'hardhat-abi-exporter';
import "hardhat-gas-reporter";
import { type HardhatUserConfig } from "hardhat/config";

import './hardhat/tasks';
import { API_KEY_ALCHEMY, API_KEY_ARBISCAN, API_KEY_BASESCAN, API_KEY_BSCSCAN, API_KEY_ETHERSCAN, API_KEY_OPBNBSCAN, API_KEY_POLYGONSCAN, DEFNDER_API_KEY, DEFNDER_API_SECRET, ENV_NETWORK_HARDHAT_FORK_TARGET, ETHERNAL_API_KEY, OWNER_ADDRESS, OWNER_MNEMONIC, REPORT_GAS } from './constant/instance';

// #endregion ➤ 📦 Package Imports

interface INetworkObject
{
  strRpc: string;
  chainId: number;
}

/**
 * @author
 *  @migbash
 * @summary
 *  🟦 HELPER
 * @description
 *  📝 Get Alchemy RPC string.
 */
function getNetworkObject
(
  network: INetwork
): INetworkObject
{
  const
    /**
     * @description
     * 📝 Network object
     */
    objNetwork: INetworkObject =
    {
      strRpc: '',
      chainId: 0
    }
  ;

  if (network == 'ethereum_mainnet')
  {
    objNetwork.strRpc = `https://eth-mainnet.g.alchemy.com/v2/${API_KEY_ALCHEMY}`;
    objNetwork.chainId = 1;
  }
  else if (network == 'ethereum_sepolia')
  {
    // [..] https://ethereum-sepolia-rpc.publicnode.com
    objNetwork.strRpc = `https://eth-sepolia.g.alchemy.com/v2/${API_KEY_ALCHEMY}`;
    objNetwork.chainId = 11155111;
  }
  else if (network == 'polygon_mainnet')
  {
    objNetwork.strRpc = `https://polygon-mainnet.g.alchemy.com/v2/${API_KEY_ALCHEMY}`;
    objNetwork.chainId = 137;
  }
  else if (network == 'polygon_amony')
  {
    objNetwork.strRpc = `https://polygon-amoy.g.alchemy.com/v2/${API_KEY_ALCHEMY}`;
    objNetwork.chainId = 80002;
  }
  else if (network == 'arbitrum_mainnet')
  {
    objNetwork.strRpc = `https://arb-mainnet.g.alchemy.com/v2/${API_KEY_ALCHEMY}`;
    objNetwork.chainId = 42161;
  }
  else if (network == 'arbitrum_sepolia')
  {
    objNetwork.strRpc = `https://arb-sepolia.g.alchemy.com/v2/${API_KEY_ALCHEMY}`;
    objNetwork.chainId = 421614;
  }
  else if (network == 'base_mainnet')
  {
    objNetwork.strRpc = `https://base-mainnet.g.alchemy.com/v2/${API_KEY_ALCHEMY}`;
    objNetwork.chainId = 8453;
  }
  else if (network == 'base_sepolia')
  {
    objNetwork.strRpc = `https://base-sepolia.g.alchemy.com/v2/${API_KEY_ALCHEMY}`;
    objNetwork.chainId = 84532;
  }
  else if (network == 'binance_mainnet')
  {
    // 🔗 learn-more :: https://docs.bnbchain.org/bnb-smart-chain/developers/rpc/#rpc-endpoints-for-bnb-smart-chain
    objNetwork.strRpc = 'https://bsc-dataseed.bnbchain.org';
    objNetwork.chainId = 56;
  }
  else if (network == 'binance_testnet')
  {
    objNetwork.strRpc = 'https://data-seed-prebsc-1-s1.bnbchain.org:8545';
    objNetwork.chainId = 97;
  }
  else if (network == 'opbnb_mainnet')
  {
    // 🔗 learn-more :: https://docs.bnbchain.org/bnb-opbnb/get-started/network-info/#rpc-endpoints
    objNetwork.strRpc = 'https://opbnb-mainnet-rpc.bnbchain.org';
    objNetwork.chainId = 204;
  }
  else if (network == 'opbnb_testnet')
  {
    // 🔗 learn-more :: https://docs.bnbchain.org/bnb-opbnb/get-started/network-info/#rpc-endpoints
    objNetwork.strRpc = 'https://opbnb-testnet-rpc.publicnode.com';
    objNetwork.chainId = 5611;
  }

  return objNetwork;
}

const config: HardhatUserConfig =
{
  /**
   * @description
   *  📝 Available networks configured for deployment.
   */
  networks:
  {
    /**
     * @description
     * 📝 `LOCAL` blockchain network instance
     */
    localhost:
    {
      // ╭─────
      // │ NOTE: WARNING: IMPORTANT CRITICAL
      // │ Requires an already 'RUNNING' Hardhat Network node to be present in the background.
      // ╰─────
      url: "http://127.0.0.1:8545"
    },
    /**
     * @description
     * 📝 Hardhat Local Node (Testnet)
     */
    hardhat:
    {
      /**
       * @description
       * 📝 Owner of contract
       */
      from: OWNER_ADDRESS,
      /**
       * @description
       * 📝 Accounts to be imported to the network
       */
      accounts:
      {
        mnemonic: OWNER_MNEMONIC,
        accountsBalance: '100000000000000000000000000'
      },
      /**
       * @description
       *  📝 Its value should be "auto" or a number (in wei).
       *  This parameter behaves like gas.
       *  Default value: "auto".
       *  Note that when using ethers this value will not be applied.
       */
      gasPrice: "auto",
      /**
       * @description
       *  📝 Its value should be "auto" or a number.
       *  If a number is used, it will be the gas limit used by default in every transaction.
       *  If "auto" is used, the gas limit will be automatically estimated.
       *  Default value: the same value as blockGasLimit.
       *  Note that when using ethers this value will not be applied.
       */
      gas: 2100000,
      /**
       * @description
       * 📝 The block gas limit to use in Hardhat Network's blockchain.
       * Default value: 30_000_000.
       */
      blockGasLimit: 9500000000000,
      /**
       * @dev
       *  - WARNING: IMPORTANT
       * @description
       * 📝 Network `chainId`
       */
      chainId: getNetworkObject(ENV_NETWORK_HARDHAT_FORK_TARGET).chainId,
      /**
       * @description
       * 📝 Network to be `forked` (options)
       */
      forking:
      {
        /**
         * @description
         *  📝 Optional boolean to switch 'on' or 'off' the fork functionality.
         *  Default value: 'true' if url is set, false otherwise.
         */
        enabled: true,
        /**
         * @dev
         *  - WARNING: IMPORTANT
         * @description
         *  📝 URL that points to a JSON-RPC node with state that you want to fork off.
         *  |: There's no default value for this field.
         *  |: It must be provided for the fork to work.
         */
        url: getNetworkObject(ENV_NETWORK_HARDHAT_FORK_TARGET).strRpc
      }
    },
    /**
     * @description
     * 📝 Ethereum (Testnet) Sepolia
     */
    ethereum_sepolia:
    {
      from: OWNER_ADDRESS,
      url: getNetworkObject('ethereum_sepolia').strRpc,
      chainId: getNetworkObject('ethereum_sepolia').chainId,
      gasPrice: 20000000000,
      accounts:
      {
        mnemonic: OWNER_MNEMONIC
      },
    },
    /**
     * @description
     * 📝 Ethereum (Mainnet)
     */
    ethereum_mainnet:
    {
      from: OWNER_ADDRESS,
      url: getNetworkObject('ethereum_mainnet').strRpc,
      chainId: getNetworkObject('ethereum_mainnet').chainId,
      gasPrice: 20000000000,
      accounts:
      {
        mnemonic: OWNER_MNEMONIC
      },
    },
    /**
     * @description
     * 📝 Polygon (Testnet) Amony
     */
    polygon_amony:
    {
      from: OWNER_ADDRESS,
      url: getNetworkObject('polygon_amony').strRpc,
      chainId: getNetworkObject('polygon_amony').chainId,
      gasPrice: 20000000000,
      accounts:
      {
        mnemonic: OWNER_MNEMONIC
      },
    },
    /**
     * @description
     * 📝 Polygon (Mainnet)
     */
    polygon_mainnet:
    {
      from: OWNER_ADDRESS,
      url: getNetworkObject('polygon_mainnet').strRpc,
      chainId: getNetworkObject('polygon_mainnet').chainId,
      gasPrice: 20000000000,
      accounts:
      {
        mnemonic: OWNER_MNEMONIC
      },
    },
    /**
     * @description
     * 📝 Base Mainnet
     */
    base_mainnet:
    {
      from: OWNER_ADDRESS,
      url: getNetworkObject('base_mainnet').strRpc,
      chainId: getNetworkObject('base_mainnet').chainId,
      gasPrice: 20000000000,
      accounts:
      {
        mnemonic: OWNER_MNEMONIC
      },
    },
    /**
     * @description
     * 📝 Base (Testnet) Sepolia
     */
    base_sepolia:
    {
      from: OWNER_ADDRESS,
      url: getNetworkObject('base_sepolia').strRpc,
      chainId: getNetworkObject('base_sepolia').chainId,
      gasPrice: 20000000000,
      accounts:
      {
        mnemonic: OWNER_MNEMONIC
      },
    },
    /**
     * @description
     * 📝 Arbitrum Mainnet
     */
    arbitrum_mainnet:
    {
      from: OWNER_ADDRESS,
      url: getNetworkObject('arbitrum_mainnet').strRpc,
      chainId: getNetworkObject('arbitrum_mainnet').chainId,
      gasPrice: 20000000000,
      accounts:
      {
        mnemonic: OWNER_MNEMONIC
      },
    },
    /**
     * @description
     * 📝 Arbitrum (Testnet) Sepolia
     */
    arbitrum_sepolia:
    {
      from: OWNER_ADDRESS,
      url: getNetworkObject('arbitrum_sepolia').strRpc,
      chainId: getNetworkObject('arbitrum_sepolia').chainId,
      gasPrice: 20000000000,
      accounts:
      {
        mnemonic: OWNER_MNEMONIC
      },
    },
    /**
     * @description
     * 📝 Binance (Testnet) Binance Smart Chain
     */
    binance_testnet:
    {
      from: OWNER_ADDRESS,
      url: getNetworkObject('binance_testnet').strRpc,
      chainId: getNetworkObject('binance_testnet').chainId,
      gasPrice: 20000000000,
      accounts:
      {
        mnemonic: OWNER_MNEMONIC
      }
    },
    /**
     * @description
     * 📝 Binance (Mainnet) Binance Smart Chain
     */
    binance_mainnet:
    {
      from: OWNER_ADDRESS,
      url: getNetworkObject('binance_mainnet').strRpc,
      chainId: getNetworkObject('binance_mainnet').chainId,
      gasPrice: 20000000000,
      accounts:
      {
        mnemonic: OWNER_MNEMONIC
      }
    },
    /**
     * @description
     * 📝 Binance (Testnet) opBNB
     */
    opbnb_testnet:
    {
      from: OWNER_ADDRESS,
      url: getNetworkObject('opbnb_testnet').strRpc,
      chainId: getNetworkObject('opbnb_testnet').chainId,
      gasPrice: 20000000000,
      accounts:
      {
        mnemonic: OWNER_MNEMONIC
      }
    },
    /**
     * @description
     * 📝 Binance (Mainnet) opBNB
     */
    opbnb_mainnet:
    {
      from: OWNER_ADDRESS,
      url: getNetworkObject('opbnb_mainnet').strRpc,
      chainId: getNetworkObject('opbnb_mainnet').chainId,
      gasPrice: 20000000000,
      accounts:
      {
        mnemonic: OWNER_MNEMONIC
      }
    }
  },
  /**
   * @description
   *  📝 Solidity (compiler) configuration.
   */
  solidity:
  {
    // version: '0.8.24',
    compilers:
    [
      {
        version: '0.8.24',
        settings:
        {
          viaIR: true,
          optimizer:
          {
            enabled: true,
            details:
            {
              yulDetails:
              {
                optimizerSteps: "u",
              },
            },
          }
        },
      },
      {
        version: "0.5.2",
        settings: { }
      }
    ],
    overrides:
    {
      "contracts/MaticTokenCopy.sol":
      {
        version: "0.5.2",
      }
    }
  },
  /**
   * @description
   *  📝 Key project paths.
   */
  paths:
  {
    sources: "./contracts",
    tests: "./test",
    artifacts: "./artifacts",
    cache: "./cache",
  },
  /**
   * @description
   * 📝 Hardhat (plugin) configuration.
   */
  etherscan:
  {
    apiKey:
    {
      // Layer-1 :: (ETH) Ethereum
      mainnet: API_KEY_ETHERSCAN,
      sepolia: API_KEY_ETHERSCAN,
      // Layer-2 :: (ETH) Polygon
      polygon: API_KEY_POLYGONSCAN,
      polygonAmoy: API_KEY_POLYGONSCAN,
      // Layer-2 :: (ETH) Arbitrum
      arbitrumOne: API_KEY_ARBISCAN,
      arbitrumSepolia: API_KEY_ARBISCAN,
      // Layer-2 :: (ETH) Base
      base: API_KEY_BASESCAN,
      baseSepolia: API_KEY_BASESCAN,
      // Layer-1 :: (BSC) BinanceSmartChain
      bsc: API_KEY_BSCSCAN,
      bscTestnet: API_KEY_BSCSCAN,
      // Layer-2 :: (BSC) opBNB
      opBNB: API_KEY_OPBNBSCAN,
      opBNBTestnet: API_KEY_OPBNBSCAN,
    },
    customChains:
    [
      {
        network: "polygonAmoy",
        chainId: 80002,
        urls:
        {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: "https://amoy.polygonscan.com",
        }
      },
      {
        network: "arbitrumSepolia",
        chainId: 421614,
        urls:
        {
          apiURL: "https://api-sepolia.arbiscan.io/api",
          browserURL: "https://sepolia.arbiscan.io",
        }
      },
      {
        network: "baseSepolia",
        chainId: 84532,
        urls:
        {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org",
        }
      },
      {
        network: "opBNB",
        chainId: 204,
        urls:
        {
          apiURL: "https://api-opbnb.bscscan.com/api",
          browserURL: "https://opbnb.bscscan.com",
        }
      },
      {
        network: "opBNBTestnet",
        chainId: 5611,
        urls:
        {
          apiURL: "https://api-opbnb-testnet.bscscan.com/api",
          browserURL: "https://opbnb-testnet.bscscan.com/",
        }
      }
    ]
  },
  /**
   * @description
   * 📝 Ethernal (plugin) configuration.
   * @see https://www.npmjs.com/package/hardhat-ethernal
   * @see (alternative) https://www.quicknode.com/guides/infrastructure/blockchain-data-tools/how-to-run-the-expedition-block-explorer-for-ethereum
   * @see (alternative) https://github.com/Tenderly/hardhat-tenderly
   */
  ethernal:
  {
    /**
     * @description
     * 📝 Ethernal API Account Token
     */
    apiToken: ETHERNAL_API_KEY,
    /**
     * @description
     * 📝 If set to true, plugin will upload AST, and you'll be able to use the storage feature (longer sync time though)
     */
    uploadAst: true,
    /**
     * @description
     * 📝 If set to true, plugin will not sync blocks & txs
     */
    disableSync: false,
    /**
     * @description
     * 📝 If set to true, plugin won't trace transaction
     */
    disableTrace: false,
    /**
     * @description
     * 📝 If set to true, the plugin will be disabled, nohting will be synced, ethernal.push won't do anything either
     */
    disabled: false,
    /**
     * @description
     * 📝 If set to true, will display this config object on start and the full error object
     */
    verbose: true
  },
  /**
   * @description
   * 📝 ABI Exporter (plugin) configuration.
   * @see https://www.npmjs.com/package/hardhat-abi-exporter
   */
  abiExporter:
  {
    /**
     * @description
     * 📝 path to ABI export directory (relative to Hardhat root)
     */
    path: './abi',
    /**
     * @description
     * 📝 whether to automatically export ABIs during compilation
     */
    runOnCompile: true
  },
  /**
   * @description
   * 📝 Gas Reporter (plugin) configuration.
   * @see https://www.npmjs.com/package/hardhat-gas-reporter
   */
  gasReporter:
  {
    enabled: REPORT_GAS !== undefined,
    currency: "USD",
  },
  /**
   * @description
   * 📝 Openzeppelin-Defender (plugin) configuration.
   * @see https://www.npmjs.com/package/@openzeppelin/hardhat-defender
   * @see https://www.npmjs.com/package/@openzeppelin/hardhat-upgrades
   * @see https://docs.openzeppelin.com/defender
   */
  defender:
  {
    // ▓ NOTE:
    // ▓ @see :> https://stackoverflow.com/questions/54496398/typescript-type-string-undefined-is-not-assignable-to-type-string
    apiKey: DEFNDER_API_KEY,
    apiSecret: DEFNDER_API_SECRET,
  },
  // mocha:
  // {
  //   /** @description ability to `increase` testing `timeout`, ideal for `forking` to complete */
  //   timeout: 2000000
  // },
};

export default config;
