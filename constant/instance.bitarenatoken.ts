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
// │ |: Instance (Bitarena) Variables Definitions
// ╰──────────────────────────────────────────────────────────────────────────────────╯

// #region ➤ 📦 Package Imports

import { ENV_DEPLOY_TARGET, ENV_NETWORK_TARGET } from './instance';

// #endregion ➤ 📦 Package Imports

interface IEnvironment
{
  deployment:
  {
    [key in IEnvrionment]:
    {
      /**
       * @description
       * 📝 smart contract deployment name
       */
      name: string;
      /**
       * @description
       * 📝 smart contract deployment symbol
       */
      symbol: string;
      /**
       * @description
       * 📝 addressFee is the fee address of the environment.
       */
      addressFee: string;
      /**
       * @description
       * 📝 listAddressTeam is the list of team addresses.
       */
      listAddressTeam: string[];
    }
  }
  network:
  {
    [key in IChain]: Partial <
      {
        [key in IChainSubNetwork]:
        {
          /**
           * @description
           * 📝 addressUniswapV3Factory is the uniswap v3 factory contract address.
           */
          addressUniswapV3Factory?: string;
          /**
           * @description
           * 📝 addressMatic is the matic contract address.
           */
          addressMatic?: string;
          /**
           * @description
           * 📝 addressPermit2 is the permit2 contract address.
           */
          addressPermit2?: string;
        }
      }
    >
  }
}

/**
 * @author
 *  @migbash
 * @summary
 *  🟦 HELPER
 * @description
 *  📝 identifies the current environment.
 * @return { IEnvironment }
 *  📤 environment data.
 */
export function identifyEnvironment
(
): IEnvironment['deployment']['staging'] & IEnvironment['network']['ethereum']['mainnet']
{
  const
    /**
     * @description
     * 📝 environment deployment target.
     */
    environmentDeployment: IEnvironment['deployment'] =
    {
      /**
       * @description
       * 📝 (production) list of team addresses.
       */
      production:
      {
        name: 'Bitarena',
        symbol: 'BTA',
        addressFee: '0x4A60e8B372ba9Ea596b03c6a0c43bf46A55Ce26C',
        listAddressTeam:
        [
          /* founding */ '0x4A60e8B372ba9Ea596b03c6a0c43bf46A55Ce26C',
          /* advisory */ '0x9026Df2a064603D1592748b983d16657dC36B8Dc',
          /* investor */ '0xF04376654a4725C49645626fa5699c24205a1239',
          /* team */ '0x12BED213404BaF5947496Db161f7fA25a315E173',
          /* participant */ '0x475c5243d8442935E84027Fc5c8EAC3Dabd5bDEc',
          /* marketing */ '0xddD5CF13684Ae3b227548c766F13FFbaD1F83dD0',
          /* liquidity */ '0x53c3d0F4ee3DDf4e9D000f0F84F1fC8E797Dfe86',
          /* reserve */ '0x862d13CE84df76D1Ea04b8a96fb2F9cDF7353bd6'
        ]
      },
      /**
       * @description
       * 📝 (staging) list of team addresses.
       */
      staging:
      {
        name: 'BitarenaTest',
        symbol: 'BTAT',
        addressFee: '0xA7B90A598ba81977dA54DA40AAAD3e30d702346f',
        listAddressTeam:
        [
          /* founding */ '0xA43B84b58aC6a21A03391971Bd274fe7Eec378Eb',
          /* advisory */ '0xA43B84b58aC6a21A03391971Bd274fe7Eec378Eb',
          /* investor */ '0xA43B84b58aC6a21A03391971Bd274fe7Eec378Eb',
          /* team */ '0xA43B84b58aC6a21A03391971Bd274fe7Eec378Eb',
          /* participant */ '0xA43B84b58aC6a21A03391971Bd274fe7Eec378Eb',
          /* marketing */ '0xA43B84b58aC6a21A03391971Bd274fe7Eec378Eb',
          /* liquidity */ '0xA43B84b58aC6a21A03391971Bd274fe7Eec378Eb',
          /* reserve */ '0xA43B84b58aC6a21A03391971Bd274fe7Eec378Eb'
        ]
      }
    },
    /**
     * @description
     * 📝 environment network target.
     * IMPORTANT: The addresses are for reference only.
     * 🔗 read-more |:| https://docs.uniswap.org/contracts/v3/reference/deployments
     * 🔗 read-more |:| https://developer.pancakeswap.finance/contracts/permit2/addresses
     */
    environmentNetwork: IEnvironment['network'] =
    {
      ethereum:
      {
        mainnet:
        {
          // addressUniswapV3Factory: '0x1F98431c8aD98523631AE4a59f267346ea31F984',
          // addressMatic: '0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0',
          // ╭─────
          // │ NOTE:
          // │ |: UniswapPermit2 :: 0x000000000022D473030F116dDEE9F6B43aC78BA3
          // │ |: PancakePermit2 :: 0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768
          // ╰─────
          addressPermit2: '0x000000000022D473030F116dDEE9F6B43aC78BA3'
        },
        sepolia:
        {
          // addressUniswapV3Factory: '0x0227628f3F023bb0B980b67D528571c95c6DaC1c',
          // addressMatic: '0x3fd0A53F4Bf853985a95F4Eb3F9C9FDE1F8e2b53',
          // ╭─────
          // │ NOTE:
          // │ |: UniswapPermit2 :: 0x000000000022D473030F116dDEE9F6B43aC78BA3
          // │ |: PancakePermit2 :: 0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768
          // ╰─────
          addressPermit2: '0x000000000022D473030F116dDEE9F6B43aC78BA3'
        }
      },
      polygon:
      {
        mainnet:
        {
          // addressUniswapV3Factory: '0x1F98431c8aD98523631AE4a59f267346ea31F984',
          // addressMatic: 'NaN',
          // ╭─────
          // │ NOTE:
          // │ |: UniswapPermit2 :: 0x000000000022D473030F116dDEE9F6B43aC78BA3
          // │ |: PancakePermit2 :: NaN
          // ╰─────
          addressPermit2: '0x000000000022D473030F116dDEE9F6B43aC78BA3'
        },
        amony:
        {
          // addressUniswapV3Factory: '0x1F98431c8aD98523631AE4a59f267346ea31F984',
          // addressMatic: 'NaN',
          // ╭─────
          // │ NOTE:
          // │ |: UniswapPermit2 :: 0x000000000022D473030F116dDEE9F6B43aC78BA3
          // │ |: PancakePermit2 :: NaN
          // ╰─────
          addressPermit2: '0x000000000022D473030F116dDEE9F6B43aC78BA3'
        }
      },
      arbitrum:
      {
        mainnet:
        {
          // addressUniswapV3Factory: '0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7',
          // addressMatic: '0xCC42724C6683B7E57334c4E856f4c9965ED682bD',
          // ╭─────
          // │ NOTE:
          // │ |: UniswapPermit2 :: 0x000000000022D473030F116dDEE9F6B43aC78BA3
          // │ |: PancakePermit2 :: 0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768
          // ╰─────
          addressPermit2: '0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768'
        },
        sepolia:
        {
          // addressUniswapV3Factory: '0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7',
          // addressMatic: '0xCC42724C6683B7E57334c4E856f4c9965ED682bD',
          // ╭─────
          // │ NOTE:
          // │ |: UniswapPermit2 :: 0x000000000022D473030F116dDEE9F6B43aC78BA3
          // │ |: PancakePermit2 :: 0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768
          // ╰─────
          addressPermit2: '0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768'
        }
      },
      base:
      {
        mainnet:
        {
          // addressUniswapV3Factory: '0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7',
          // addressMatic: '0xCC42724C6683B7E57334c4E856f4c9965ED682bD',
          // ╭─────
          // │ NOTE:
          // │ |: UniswapPermit2 :: 0x000000000022D473030F116dDEE9F6B43aC78BA3
          // │ |: PancakePermit2 :: 0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768
          // ╰─────
          addressPermit2: '0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768'
        },
        sepolia:
        {
          // addressUniswapV3Factory: '0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7',
          // addressMatic: '0xCC42724C6683B7E57334c4E856f4c9965ED682bD',
          // ╭─────
          // │ NOTE:
          // │ |: UniswapPermit2 :: 0x000000000022D473030F116dDEE9F6B43aC78BA3
          // │ |: PancakePermit2 :: 0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768
          // ╰─────
          addressPermit2: '0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768'
        }
      },
      binance:
      {
        mainnet:
        {
          // addressUniswapV3Factory: '0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7',
          // addressMatic: '0xCC42724C6683B7E57334c4E856f4c9965ED682bD',
          // ╭─────
          // │ NOTE:
          // │ |: UniswapPermit2 :: 0x000000000022D473030F116dDEE9F6B43aC78BA3
          // │ |: PancakePermit2 :: 0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768
          // ╰─────
          addressPermit2: '0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768'
        },
        testnet:
        {
          // addressUniswapV3Factory: '0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7',
          // addressMatic: '0xCC42724C6683B7E57334c4E856f4c9965ED682bD',
          // ╭─────
          // │ NOTE:
          // │ |: UniswapPermit2 :: NaN / Unkown / Same as Mainnet [?]
          // │ |: PancakePermit2 :: 0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768
          // ╰─────
          addressPermit2: '0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768'
        }
      },
      opbnb:
      {
        mainnet:
        {
          // addressUniswapV3Factory: '0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7',
          // addressMatic: '0xCC42724C6683B7E57334c4E856f4c9965ED682bD',
          // ╭─────
          // │ NOTE:
          // │ |: UniswapPermit2 :: NaN / Unkown / Same as Mainnet [?]
          // │ |: PancakePermit2 :: 0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768
          // ╰─────
          addressPermit2: '0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768'
        },
        testnet:
        {
          // addressUniswapV3Factory: '0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7',
          // addressMatic: '0xCC42724C6683B7E57334c4E856f4c9965ED682bD',
          // ╭─────
          // │ NOTE:
          // │ |: UniswapPermit2 :: NaN / Unkown / Same as Mainnet [?]
          // │ |: PancakePermit2 :: 0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768
          // ╰─────
          addressPermit2: '0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768'
        }
      }
    },
    /**
     * @description
     * 📝 environment network target.
     */
    _envNetwork = ENV_NETWORK_TARGET.split('_')
  ;

  return {
    ...environmentDeployment[ENV_DEPLOY_TARGET],
    ...environmentNetwork[_envNetwork[0] as IChain][_envNetwork[1] as IChainSubNetwork]
  };
}