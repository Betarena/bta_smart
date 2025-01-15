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
// │ |: Instance (Main) Variables Definitions
// ╰──────────────────────────────────────────────────────────────────────────────────╯

// #region ➤ 📦 Package Imports

import * as dotenv from 'dotenv';

// #endregion ➤ 📦 Package Imports

dotenv.config();

export const
  // ╭─────
  // │ NOTE: |:| Destructing Environment Variables
  // ╰─────
  {
    // ╭──────────────────────────────────────────────────────────────────────────────────╮
    // │ ⛔️ │ METAMASK                                                                    │
    // ╰──────────────────────────────────────────────────────────────────────────────────╯
    OWNER_MNEMONIC,
    OWNER_ADDRESS,
    // ╭──────────────────────────────────────────────────────────────────────────────────╮
    // │ 🔳 │ HARDHAT                                                                     │
    // ╰──────────────────────────────────────────────────────────────────────────────────╯
    REPORT_GAS,
    DEFNDER_API_KEY,
    DEFNDER_API_SECRET,
    API_KEY_ETHERSCAN,
    API_KEY_POLYGONSCAN,
    API_KEY_ARBISCAN,
    API_KEY_BASESCAN,
    API_KEY_BSCSCAN,
    API_KEY_OPBNBSCAN,
    API_KEY_ALCHEMY,
    // ╭──────────────────────────────────────────────────────────────────────────────────╮
    // │ 💠 │ HARDHAT (PLUGIN) ETERHNAL                                                   │
    // ╰──────────────────────────────────────────────────────────────────────────────────╯
    ETHERNAL_API_KEY,
    // ╭──────────────────────────────────────────────────────────────────────────────────╮
    // │ 🟦 │ HARDHAT (PLUGIN) DEFENDER                                                   │
    // ╰──────────────────────────────────────────────────────────────────────────────────╯
    DEFENDER_RELAYER_ADDRESS,
    DEFENDER_RELAYER_ID,
    // ╭──────────────────────────────────────────────────────────────────────────────────╮
    // │ 🔥 │ ENVIRONMENT SWITCH                                                          │
    // ╰──────────────────────────────────────────────────────────────────────────────────╯
    ENV_DEPLOY_TARGET,
    ENV_NETWORK_TARGET,
    ENV_NETWORK_HARDHAT_FORK_TARGET,
    ENV_NETWORK_HARDHAT_DEPLOYMENT_TARGET,
  } = process.env
;