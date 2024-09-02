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
// │ Betarena (TS.Module) || Bitarena Deployment (Normal)                             │
// ╰──────────────────────────────────────────────────────────────────────────────────╯

// #region ➤ 📦 Package Imports

import { ethernal, ethers, network, upgrades } from 'hardhat';
import fs from 'fs-extra';
import { table } from "table";

import { ENV_DEPLOY_TARGET, ENV_NETWORK_HARDHAT_DEPLOYMENT_TARGET, ENV_NETWORK_TARGET, identifyEnvironment } from '../constant/instance.bitarenatoken';

// #endregion ➤ 📦 Package Imports

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
      = await upgrades.deployProxy
      (
        TOKEN_FACTORY,
        [
          ENVIRONMENT_DATA.name,
          ENVIRONMENT_DATA.symbol,
          ENVIRONMENT_DATA.addressFee,
          ...ENVIRONMENT_DATA.listAddressTeam,
          // ENVIRONMENT_DATA.addressUniswapV3Factory,
          // ENVIRONMENT_DATA.addressMatic
          ENVIRONMENT_DATA.addressPermit2
        ],
        { initializer: 'initialize' }
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
        ['Contract Address', CONTRACT_ADDRESS]
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

  await fs.ensureFile('./logs/deployment.bitarena.json');

  let
    /**
     * @description
     * 📝 debug list.
     */
    listDebug = await fs.readJSON('./logs/deployment.bitarena.json') as any
  ;

  // [🐞]
  // console.log(listDebug);

  const
    /**
     * @description
     * 📝 debug object.
     */
    objNewDebug
      = {
        timestamp: new Date().toISOString(),
        config:
        {
          ENV_DEPLOY_TARGET,
          ENV_NETWORK_TARGET,
          ENV_NETWORK_HARDHAT_DEPLOYMENT_TARGET
        },
        network:
        {
          name: network?.name,
          chainId: network.config.chainId,
          owner: network.config.from ?? '0x0',
          gasPrice: network.config.gasPrice,
          gasLimit: network.config.gas,
          gasMultiplier: network.config.gasMultiplier
        },
        contract:
        {
          name: 'BitarenaToken',
          address: CONTRACT_ADDRESS,
          arguments: ENVIRONMENT_DATA,
        },
        comments: []
      }
  ;

  listDebug.push(objNewDebug);

  // ╭─────
  // │ NOTE: IMPORTANT |:| log contract deployment data.
  // ╰─────
  await fs.outputFile
  (
    './logs/deployment.bitarena.json',
    JSON.stringify(listDebug, null, 2),
    {
      flag: 'w'
    }
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