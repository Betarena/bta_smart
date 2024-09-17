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
// │ |: Script Debug (BetarenaBank) Helper
// ╰──────────────────────────────────────────────────────────────────────────────────╯

// #region ➤ 📦 Package Imports

import { network } from 'hardhat';

import { ENV_DEPLOY_TARGET, ENV_NETWORK_TARGET, ENV_NETWORK_HARDHAT_DEPLOYMENT_TARGET } from "../constant/instance";
import { readFromFileAsJson, writeToFile } from "../utils/io";

// #endregion ➤ 📦 Package Imports

/**
 * @author
 *  @migbash
 * @summary
 *  🟥 MAIN
 * @description
 *  📝 debug herlper for 'script/**' deployments.
 * @param { string } path
 *  💠 **REQUIRED** Path of debug file.
 * @param { string } contractAddress
 *  💠 **REQUIRED** Deployment contract address.
 * @param { any } environmentData
 *  💠 **REQUIRED** Environment variables passed to contract on construction.
 * @returns { Promise < void > }
 */
export async function debug
(
  path: string,
  contractAddress: string,
  environmentData: any
): Promise < void >
{
  // [🐞]
  if (ENV_DEPLOY_TARGET == 'production')
    console.log("🟥🟥🟥 :: Deploying Production Target");
  ;

  // [🐞]
  console.log(`🔹 [var] ENV_DEPLOY_TARGET ${ENV_DEPLOY_TARGET}`);
  console.log(`🔹 [var] ENV_NETWORK_TARGET ${ENV_NETWORK_TARGET}`);

  let
    /**
     * @description
     * 📝 debug list.
     */
    dataDebug =
      await readFromFileAsJson
      <
        Array < any >
      >
      (
        path
      )
  ;

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
          address: contractAddress,
          arguments: environmentData,
        },
        comments: []
      }
  ;

  dataDebug.push(objNewDebug);

  // ╭─────
  // │ NOTE: IMPORTANT |:| log contract deployment data.
  // ╰─────
  await writeToFile
  (
    path,
    dataDebug
  );

  return;
}