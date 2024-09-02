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
// │ HardHat Tasks
// │ 🔗 read-more |:| https://hardhat.org/guides/create-task.html
// ╰──────────────────────────────────────────────────────────────────────────────────╯

// #region ➤ 📦 Package Imports

import { HardhatNetworkAccountConfig } from "hardhat/types/config.js";
import { task, type HardhatUserConfig } from "hardhat/config";
import { table } from "table";
import '@nomicfoundation/hardhat-toolbox';

// #endregion ➤ 📦 Package Imports

task
(
  "info-network",
  "🚏 [checkpoint] Prints list of accounts",
  async (
    taskArgs,
    hre
  ): Promise < void > =>
  {
    // [🐞]
    console.info
    (
      table
      (
        [
          ['💮 Network', hre.network.name],
          // ['💮 Provider', hre.network.provider],
          ['💮 Chain ID', hre.network.config.chainId],
          ['💮 Accounts', (hre.network.config.accounts as HardhatNetworkAccountConfig[]).length],
          ['💮 From', hre.network.config.from]
        ]
      )
    );

    return;
  }
);

task
(
  "info-accounts",
  "🚏 [checkpoint] Prints list of accounts",
  async (
    taskArgs,
    hre
  ): Promise < void > =>
  {
    // [🐞]
    console.info
    (
      table
      (
        [
          ['💮 Accounts', (hre.network.config.accounts as HardhatNetworkAccountConfig[]).length],
          ['💮 From', hre.network.config.from]
        ]
      )
    );

    // [🐞]
    console.log(`🔹 [var] target contract address ${process.env._TEMP_ADDRESS}`);

    const
      // [🐞]
      dataLog: any[][] = [],
      /**
       * @description
       * 📝 Get all accounts on network.
       */
      accounts = await hre.ethers.getSigners()
    ;

    // ╭─────
    // │ NOTE: |:| loop over each account on network.
    // ╰─────
    for (const account of accounts)
    {
      const
        /**
         * @description
         * 📝 Get account address.
         */
        address = account?.address
      ;

      console.log(`🔹 [var] account address ${address}`);

      const
        /**
         * @description
         * 📝 Get account balance
         */
        nativeBalance = hre.ethers.formatEther(await hre.ethers.provider.getBalance(account))
      ;

      console.log(`🔹 [var] account nativeBalance ${nativeBalance}`);

      const
        /**
         * @description
         * 📝 Get ERC20 balance
         */
        Erc20Contract = await hre.ethers.getContractAt('IERC20', process.env._TEMP_ADDRESS),
        /**
         * @description
         * 📝 Get account balance
         */
        accountBalance = hre.ethers.formatEther(await Erc20Contract.balanceOf(address))
      ;

      // [🐞]
      dataLog.push([address, nativeBalance, accountBalance]);
    }

    // [🐞]
    console.info
    (
      table
      (
        [
          ['🧾 Address', '💰 Balance (ETH)', '💰 Balance (USDC)'],
          ...dataLog
        ]
      )
    );
  }
);

task
(
  "info-uniswap",
  "🚏 [checkpoint] For presence of correct smart-contracts in fork/localhost node",
  async (
    taskArgs,
    hre
  ): Promise < void > =>
  {
    // [🐞]
    console.info
    (
      table
      (
        [
          ['💮 Network', hre.network.name],
          ['💮 From', hre.network.config.from]
        ]
      )
    );

    const
      /**
       * @description
       * 📝 Get UniswapV3Factory contract.
       */
      // uniswapV3Factory = await hre.ethers.getContractAt('IUniswapV3Factory', `0x1F98431c8aD98523631AE4a59f267346ea31F984`),
      /**
       * @description
       * 📝 Get UniswapV3Pool contract.
       */
      uniswapV3Pool = await hre.ethers.getContractAt('IUniswapV3Pool', `0x936A029088C242147ae4E5Eae3B992E3BB493b56`),
      /**
       * @description
       * 📝 Get sqrtPriceX96.
       */
      sqrtPow96 = 79444094810487954288659649444 // Number((await uniswapV3Pool.slot0()).sqrtPriceX96)
    ;

    // console.log(`🔹 [var] uniswapV3Factory ${await uniswapV3Factory.getAddress()}`);
    // console.log(`🔹 [var] uniswapV3Factory ${await uniswapV3Factory.owner()}`);
    console.log(`🔹 [var] uniswapV3Pool ${await uniswapV3Pool.slot0()}`);
    console.log(sqrtPow96**2 / 2**192 * 10**18);

    return;
  }
);