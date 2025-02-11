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
// │ Betarena (Module)
// │ |: Script Deployment (Bitarena) Definitions
// ╰──────────────────────────────────────────────────────────────────────────────────╯

// #region ➤ 📦 Package Imports

import { ethernal, ethers, network } from 'hardhat';
import { table } from "table";

import { identifyEnvironment } from '../constant/instance.bitarenatoken';
import { ENV_NETWORK_HARDHAT_DEPLOYMENT_TARGET } from '../constant/instance';
import { debug } from '../utils/debug';

// #endregion ➤ 📦 Package Imports

const
  /**
   * @description
   * 📝 debug file.
   */
  debugFile = './logs/deployment.bitarena.json'
;

/**
 * @author
 *  @migbash
 * @summary
 *  🟥 MAIN
 * @description
 *  📝 deploys target `BitarenaToken` contract via `hardhat/ethers.js`.
 * @return { Promise < void > }
 */
async function main
(
): Promise < void >
{
  // [🐞]
  console.log("🚏 [checkpoint] Deploying BitarenaToken");

  const
    /**
     * @description
     * 📝 environment data.
     */
    ENVIRONMENT_DATA = identifyEnvironment(),
    /**
     * @description
     * 📝 get contract factory.
     */
    TOKEN_FACTORY
      = await ethers.getContractFactory("BitarenaToken"),
    /**
     * @description
     * 📝 deploy contract.
     * @dev
     * (or) upgrades.deployProxy(TOKEN_FACTORY, { initializer: 'initialize' });
     */
    CONTRACT
      = await TOKEN_FACTORY.deploy
      (
        ENVIRONMENT_DATA.name,
        ENVIRONMENT_DATA.symbol,

        ENVIRONMENT_DATA.listAddressTeam[0],
        ENVIRONMENT_DATA.listAddressTeam[1],
        ENVIRONMENT_DATA.listAddressTeam[2],
        ENVIRONMENT_DATA.listAddressTeam[3],
        ENVIRONMENT_DATA.listAddressTeam[4],
        ENVIRONMENT_DATA.listAddressTeam[5],
        ENVIRONMENT_DATA.listAddressTeam[6],
        ENVIRONMENT_DATA.listAddressTeam[7],

        // ENVIRONMENT_DATA.addressUniswapV3Factory,
        // ENVIRONMENT_DATA.addressMatic
        ENVIRONMENT_DATA.addressFee,
        ENVIRONMENT_DATA.addressPermit2!,
        ENVIRONMENT_DATA.addressUniversalRouter!
      ),
    /**
     * @description
     * 📝 Contract address
     */
    CONTRACT_ADDRESS = await CONTRACT.getAddress()
  ;

  // [🐞]
  console.info
  (
    table
    (
      [
        ['Network', network?.name],
        ['Contract Address', CONTRACT_ADDRESS],
        ['Transaction Hash', CONTRACT.deploymentTransaction()?.hash]
      ]
    )
  );

  // ╭─────
  // │ CHECK: for Ethernal deployment for 'localhost'.
  // ╰─────
  if (ENV_NETWORK_HARDHAT_DEPLOYMENT_TARGET === 'localhost')
    await ethernal.push
    (
      {
        name: 'BitarenaToken',
        address: CONTRACT_ADDRESS,
        workspace: 'Testnet',
      }
    );
  ;

  await debug
  (
    debugFile,
    CONTRACT_ADDRESS,
    ENVIRONMENT_DATA,
    CONTRACT.deploymentTransaction()?.hash ?? '0x0'
  );

  return;
}

main()
  .then
  (
    () =>
    process.exit(0)
  )
  .catch
  (
    error =>
    {
      console.error(JSON.stringify(error));
      process.exit(1);
    }
  )
;