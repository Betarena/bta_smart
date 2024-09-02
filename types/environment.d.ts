declare global
{
  namespace NodeJS
  {
    /**
     * @description
     * - 📝 Custom environment variables.
     * - 📝 For more information, explore the '.env.*' complementary secrets file, in the project root (./).
     */
    interface ProcessEnv
    {
      NODE_ENV: 'development' | 'production';
      PWD: string;
      // ╭──────────────────────────────────────────────────────────────────────────────────╮
      // │ ⛔️ │ METAMASK                                                                    │
      // ╰──────────────────────────────────────────────────────────────────────────────────╯
      OWNER_ADDRESS: string;
      OWNER_MNEMONIC: string;
      // ╭──────────────────────────────────────────────────────────────────────────────────╮
      // │ 🔳 │ HARDHAT                                                                     │
      // ╰──────────────────────────────────────────────────────────────────────────────────╯
      API_KEY_ETHERSCAN: string;
      API_KEY_POLYGONSCAN: string;
      API_KEY_ALCHEMY: string;
      API_KEY_BSCSCAN: string;
      API_KEY_ARBISCAN: string;
      API_KEY_BASESCAN: string;
      API_KEY_OPBNBSCAN: string;
      REPORT_GAS: string;
      // ╭──────────────────────────────────────────────────────────────────────────────────╮
      // │ 💠 │ HARDHAT (PLUGIN) ETERHNAL                                                   │
      // ╰──────────────────────────────────────────────────────────────────────────────────╯
      ETHERNAL_EMAIL: string;
      ETHERNAL_PASSWORD: string;
      ETHERNAL_API_KEY: string;
      // ╭──────────────────────────────────────────────────────────────────────────────────╮
      // │ 🟦 │ HARDHAT (PLUGIN) DEFENDER                                                   │
      // ╰──────────────────────────────────────────────────────────────────────────────────╯
      DEFNDER_API_KEY: string;
      DEFNDER_API_SECRET: string;
      DEFNDER_TEAM_API_KEY_1: string;
      DEFNDER_TEAM_API_SECRET_1: string;
      DEFNDER_TEAM_API_KEY_2: string;
      DEFNDER_TEAM_API_SECRET_2: string;
      DEFNDER_TEAM_API_KEY_3: string;
      DEFNDER_TEAM_API_SECRET_3: string;
      DEFENDER_RELAY_ETH_ADDRESS_4: string;
      DEFENDER_RELAY_API_KEY_4: string;
      DEFENDER_RELAY_API_SECRET_4: string;
      // ╭──────────────────────────────────────────────────────────────────────────────────╮
      // │ 🔥 │ ENVIRONMENT SWITCH                                                          │
      // ╰──────────────────────────────────────────────────────────────────────────────────╯
      ENV_DEPLOY_TARGET: 'staging' | 'production';
      ENV_NETWORK_TARGET: INetwork;
      ENV_NETWORK_HARDHAT_FORK_TARGET: INetwork;
      ENV_NETWORK_HARDHAT_DEPLOYMENT_TARGET: 'localhost' & INetwork;
      _TEMP_ADDRESS: string;
    }
  }
}

export { };
