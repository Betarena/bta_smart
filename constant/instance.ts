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
    REPORT_GAS,
    DEFNDER_API_KEY,
    DEFNDER_API_SECRET,
    API_KEY_ETHERSCAN,
    API_KEY_POLYGONSCAN,
    API_KEY_ARBISCAN,
    API_KEY_BASESCAN,
    API_KEY_BSCSCAN,
    API_KEY_OPBNBSCAN,
    ETHERNAL_API_KEY,
    OWNER_MNEMONIC,
    API_KEY_ALCHEMY,
    OWNER_ADDRESS,
    ENV_DEPLOY_TARGET,
    ENV_NETWORK_TARGET,
    ENV_NETWORK_HARDHAT_FORK_TARGET,
    ENV_NETWORK_HARDHAT_DEPLOYMENT_TARGET
  } = process.env
;