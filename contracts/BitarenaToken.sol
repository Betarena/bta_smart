// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

// ╭─────
// │ NOTE:
// │ |: https://raw.githubusercontent.com/ethereum/solc-bin/gh-pages/bin/list.json
// │ |: https://github.com/OpenZeppelin/openzeppelin-contracts/issues/2580
// ╰─────
pragma solidity 0.8.24;

// #region ➤ 📦 Package Imports

// import "hardhat/console.sol";

// ╭─────
// │ 🔗 read-more |:| (npm-counterpart) https://www.npmjs.com/package/@openzeppelin/contracts-upgradeable
// ╰─────
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

// ╭─────
// │ NOTE: WARNING: IMPORTANT
// │ ➤ UniswapV1 should NO LONGER BE USED! Updated to UniswapV2.
// │ ➤ UniswapV2 should NO LONGER BE USED! Updated to UniswapV3 (latest).
// ┣─────
// │ 🔗 read-more |:| (npm-counterpart) https://www.npmjs.com/package/@uniswap/v2-periphery
// │ 🔗 read-more |:| (npm-counterpart) https://www.npmjs.com/package/@uniswap/v2-core
// ╰─────
// import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
// import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
// import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
// ╭─────
// │ 🔗 read-more |:| (npm-counterpart) https://www.npmjs.com/package/@uniswap/v3-periphery || https://github.com/Uniswap/v3-periphery
// │ 🔗 read-more |:| (npm-counterpart) https://www.npmjs.com/package/@uniswap/v3-core || https://github.com/Uniswap/v3-core/tree/main
// ╰─────
import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
// import { IPancakeV3Pool } from "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Pool.sol";

// #endregion ➤ 📦 Package Imports

/// @title BitarenaToken Contact
/// @author MigBash
/// @custom:security-contact bitarena@gmail.com
contract BitarenaToken is
  ERC20,
  ERC20Burnable,
  ERC20Permit,
  Ownable,
  ReentrancyGuard
{

  // #region ➤ 📚 LIBRARY

  using Strings for string;

  // #endregion ➤ 📚 LIBRARY

  // #region ➤ 📌 VARIABLES

  /// @notice
  ///   📝 Token initial supply
  uint256 public constant SUPPLY_TOTAL = 21000000;
  /// @notice
  ///   📝 Current circulating supply BTA Token
  uint256 public numCirculatingSupply;
  /// @notice
  ///   📝 Mapping for, general addresses that should not have imposed transaction fees.
  mapping (address addressGeneralExcluded => bool isExcluded) private mapAddressExcluded;
  /// @notice
  ///   📝 Mapping for, swap-related UniswapV3Pool (addresss) involved in BUY action logic.
  mapping (address addressUniswapV3Excluded => bool isExcludedForBuy) private mapAdrExcludedForBuy;
  /// @notice
  ///   📝 Mapping for, swap-related UniswapV3Pool (addresss) involved in SELL action logic.
  mapping (address addressUniswapV3Excluded => bool isExcludedForSell) private mapAdrExcludedForSell;
  /// @notice
  ///   📝 Mapping ofor, Bitarena Token addresses of (UniswapV3) liquidity pools.
  mapping (address addressV3Pool => bool isPool) private mapAddressV3Pool;
  /// @notice
  ///   📝 Keeping track of current SwapContext
  ///   |: Example:
  ///   |: {tx.origin} -> "{block.number}_{block.timestamp}_{tx.gas}" -> "uniswapV3PoolAddress"
  mapping (address adrTxOrigin => mapping (string strTxMetadata => address adrV3Pool)) private mapSwapContext;
  /// @notice
  ///   📝 Debugging flag
  bool public isDebugActive = true;

  struct IBetarenaAddresses
  {
    address adrFoundingTeam;
    address adrAdvisoryBoard;
    address adrInvestors;
    address adrTeam;
    address adrParticipants;
    address adrMarketing;
    address adrLiquidity;
    address adrReserve;
  }

  struct IFeeLogic
  {
    /// @notice
    ///   📝 Address of Uniswap - Permit2
    address adrUniswapPermit2;
    /// @notice
    ///   📝 Address of Uniswap - UniversalRouter
    address adrUniswapUniversalRouter;
    /// @notice
    ///   📝 Address of Betarena Fee Deposit
    address adrFeeDeposit;
    /// @notice
    ///   📝 Main BTA liquidity address (usdt/usdc; a.k.a fiat price)
    address adrBtaUsdtPool;
    /// @notice
    ///   📝 Buy Fee, expressed in dollars ($) as 0.0 (to 1 d.p)
    uint256 numBuyFee;
    /// @notice
    ///   📝 Sell Fee, expressed in dollars ($) as 0.0 (ro 1 d.p)
    uint256 numSellFee;
    /// @notice
    ///   📝 Target 'Buy' condition to be used in swap action identification
    uint256 buyCondition;
  }

  IBetarenaAddresses public instanceBetarenaAddresses;
  IFeeLogic public instanceFeeLogic;

  // #endregion ➤ 📌 VARIABLES

  // #region ➤ 📣 EVENTS

  /// @notice
  ///   📝 Debugging event for WithdrawETH
  event DebugFunctionWithdrawETH       (address indexed sender, uint256 amount);
  /// @notice
  ///   📝 Debugging event for Transaction
  event DebugTransaction               (address sender, address recipient, uint256 amount);
  /// @notice
  ///   📝 Debugging Global Variable Context - Block
  event DebugGlobalContextBlock        (uint blockNumber, uint blockTimestamp, uint blockChainid);
  /// @notice
  ///   📝 Debugging Global Variable Context - Block
  event DebugGlobalContextMsgAndTx     (bytes msgData, address msgSender, uint msgValue, address txOrigin, uint txGasPrice, address msgSenderOz, bytes msgDataOz);
  /// @notice
  ///   📝 Debugging event for Transaction (Standard)
  event DebugTransactionStandard       (address sender, address recipient);
  /// @notice
  ///   📝 Debugging event for Transaction Swap (Buy/Sell)
  event DebugTransactionSwap           (address sender, address recipient, uint256 feeAmount, string swapType);
  /// @notice
  ///   📝 Debugging event for Swap Snapshot
  event DebugSwapSnapshot              (uint160 sqrtPriceX96);
  /// @notice
  ///   📝 Debugging event for Transaction (Buy)
  event DebugTransactionSwapCheckpoint (string message);


  /// @notice
  ///   📝 Error event for Generic Error
  error ErrorGeneric               (uint256 value, string message);

  // #endregion ➤ 📣 EVENTS

  /// @notice
  ///   📝 BitarenaToken
  constructor
  (
    string memory _name,
    string memory _symbol,

    address _adrFoundingTeam,
    address _adrAdvisoryBoard,
    address _adrInvestors,
    address _adrTeam,
    address _adrParticipants,
    address _adrMarketing,
    address _adrLiquidity,
    address _adrReserve,

    address _adrFeeAddress,
    address _adrUniswapPermit2,
    address _adrUniswapUniversalRouter
  )
  ERC20(_name, _symbol)
  ERC20Permit(_name)
  Ownable(msg.sender)
  {
    instanceBetarenaAddresses.adrFoundingTeam  = _adrFoundingTeam;
    instanceBetarenaAddresses.adrAdvisoryBoard = _adrAdvisoryBoard;
    instanceBetarenaAddresses.adrInvestors     = _adrInvestors;
    instanceBetarenaAddresses.adrTeam          = _adrTeam;
    instanceBetarenaAddresses.adrParticipants  = _adrParticipants;
    instanceBetarenaAddresses.adrMarketing     = _adrMarketing;
    instanceBetarenaAddresses.adrLiquidity     = _adrLiquidity;
    instanceBetarenaAddresses.adrReserve       = _adrReserve;

    instanceFeeLogic.adrFeeDeposit             = _adrFeeAddress;
    instanceFeeLogic.adrUniswapPermit2         = _adrUniswapPermit2;
    instanceFeeLogic.adrUniswapUniversalRouter = _adrUniswapUniversalRouter;

    // [🐞]
    // solhint-disable no-console
    // console.log(unicode"🚏 [checkpoint] :: initialize(..)");
    // console.log(unicode"🔹 [var] _adrFoundingTeam :: %s", _adrFoundingTeam);
    // console.log(unicode"🔹 [var] _adrAdvisoryBoard :: %s", _adrAdvisoryBoard);
    // console.log(unicode"🔹 [var] _adrInvestors :: %s", _adrInvestors);
    // console.log(unicode"🔹 [var] _adrTeam :: %s", _adrTeam);
    // console.log(unicode"🔹 [var] _adrParticipants :: %s", _adrParticipants);
    // console.log(unicode"🔹 [var] _adrMarketing :: %s", _adrMarketing);
    // console.log(unicode"🔹 [var] _adrLiquidity :: %s", _adrLiquidity);
    // console.log(unicode"🔹 [var] _adrReserve :: %s", _adrReserve);
    // console.log(unicode"🔹 [var] _adrUniswapPermit2 :: %s", _adrUniswapPermit2);
    // console.log(unicode"🔹 [var] address(this) :: %s", address(this));
    // solhint-enable no-console

    // ╭──────────────────────────────────────────────────────────────────────────────────╮
    // │ 🟥 │ MAIN INTIALIZER LOGIC                                                       │
    // ╰──────────────────────────────────────────────────────────────────────────────────╯

    uint256 _onePercent = calcOnePercentOfTotalSupply();

    _mint(instanceBetarenaAddresses.adrFoundingTeam,  (_onePercent * 5));
    _mint(instanceBetarenaAddresses.adrAdvisoryBoard, (_onePercent * 2));
    _mint(instanceBetarenaAddresses.adrInvestors,     (_onePercent * 4));
    _mint(instanceBetarenaAddresses.adrTeam,          (_onePercent * 5));
    _mint(instanceBetarenaAddresses.adrParticipants,  (_onePercent * 10));
    _mint(instanceBetarenaAddresses.adrMarketing,     (_onePercent * 10));
    _mint(instanceBetarenaAddresses.adrLiquidity,     (_onePercent * 60));
    _mint(instanceBetarenaAddresses.adrReserve,       (_onePercent * 4));

    // Causes Error:
    // ProviderError: Error: VM Exception while processing transaction: reverted with panic code 0x11 (Arithmetic operation overflowed outside of an unchecked block)
    updateCirculatingSupply();

    mapAddressExcluded[owner()]                                    = true;
    mapAddressExcluded[address(this)]                              = true;
    mapAddressExcluded[instanceBetarenaAddresses.adrFoundingTeam]  = true;
    mapAddressExcluded[instanceBetarenaAddresses.adrAdvisoryBoard] = true;
    mapAddressExcluded[instanceBetarenaAddresses.adrInvestors]     = true;
    mapAddressExcluded[instanceBetarenaAddresses.adrTeam]          = true;
    mapAddressExcluded[instanceBetarenaAddresses.adrParticipants]  = true;
    mapAddressExcluded[instanceBetarenaAddresses.adrMarketing]     = true;
    mapAddressExcluded[instanceBetarenaAddresses.adrLiquidity]     = true;
    mapAddressExcluded[instanceBetarenaAddresses.adrReserve]       = true;

    instanceFeeLogic.numBuyFee  = 100;
    instanceFeeLogic.numSellFee = 50;
    instanceFeeLogic.buyCondition = 0;

    return;
  }

  // #region ➤ 🛠️ METHODS

  // ╭──────────────────────────────────────────────────────────────────────────────────╮
  // │ 💠 │ MISCELLENOUS / DEFAULT / IMPORTANT                                          │
  // ╰──────────────────────────────────────────────────────────────────────────────────╯

  /// @notice
  ///   📝 THIS contract keeps all ETHER sent to it, with no way to get it back.
  ///   |: Necessary method to recieve ETH from uniswap when making a swap.
  receive() external payable {}

  /// @notice
  ///   📝 [fallback] executed on a call to the contract if none of the other
  ///   |: functions match the given function signature, or if no data is supplied at all
  fallback() external payable {}

  /// @notice
  ///  📝 returns the balance of the contract
  /// @return { uint256 }
  ///   📤 balance of the contract
  function getETHBalance()
  external
  view
  returns
  (
    uint256
  )
  {
    return address(this).balance;
  }

  /// @notice
  ///   📝 withdraws the locked amount of ETH
  function withdrawETH()
  external
  nonReentrant
  onlyOwner
  {

    uint256 amount = address(this).balance;
    address payable recipient = payable(owner());
    (bool success,) = recipient.call{ value: amount }("BTA :: Amount Withdrawn from smart contract");
    if (!success) revert ErrorGeneric (0, "BTA :: Withdraw transfer failed");
    // [🔘]
    if (isDebugActive) emit DebugFunctionWithdrawETH(owner(), amount);
    return;
  }

  // ╭──────────────────────────────────────────────────────────────────────────────────╮
  // │ 🟦 │ ERC-20 IMPORTANT // CRITICAL                                                │
  // ╰──────────────────────────────────────────────────────────────────────────────────╯

  /// @notice
  ///   📝 IMPORTANT ERC-20 (Openzeppelin v.5)
  ///   |: mints new tokens
  function mint
  (
    address to,
    uint256 amount
  )
  public
  onlyOwner
  {
    _mint(to, amount);
  }

  /// @notice
  /// 📝 IMPORTANT ERC-20 (Openzeppelin v.5)
  /// |: updates (trigger) for the contract
  /// 🔗 read-more |:| https://forum.openzeppelin.com/t/where-this-beforetokentransfer-function-come-from-on-erc1155-contract/36888/3
  /// 🔗 read-more |:| https://forum.openzeppelin.com/t/why-have-the-beforetokentransfer-and-aftertokentransfer-functions-been-removed-in-the-erc721-standard-in-v5/38427
  /// 🔗 read-more |:| https://forum.openzeppelin.com/t/erc721upgradable-v5-0-breaking-changes-for-beforetokentransfer-migrating-to-update/38724/3
  /// 🔗 read-more |:| https://forum.openzeppelin.com/t/how-to-reimplement-beforetokentransfer-after-removed/38781/2
  /// 🔗 read-more |:| https://stackoverflow.com/questions/77201832/erc1155-function-has-override-specified-but-does-not-override-anything
  /// 🔗 read-more |:| https://ethereum.stackexchange.com/questions/156770/trying-to-create-a-soulbound-token-keep-getting-two-errors
  /// @custom:oz The following functions are overrides required by Solidity.
  function _update
  (
    address from,
    address to,
    uint256 value
  )
  internal
  override
  {
    // [🐞]
    // solhint-disable no-console
    // console.log(unicode"🚏 [checkpoint] :: _update(..)");
    // console.log(unicode"🔹 [var] sender :: %s", from);
    // console.log(unicode"🔹 [var] recipient :: %s", to);
    // console.log(unicode"🔹 [var] amount :: %s", value);
    // console.log(unicode"🔹 [var] msg.sender :: %s", msg.sender);
    // solhint-enable no-console

    // [🔘]
    if (isDebugActive)
    {
      emit DebugTransaction(from, to, value);
      emit DebugGlobalContextBlock(block.number, block.timestamp, block.chainid);
      emit DebugGlobalContextMsgAndTx(msg.data, msg.sender, msg.value, tx.origin, tx.gasprice, _msgSender(), _msgData());
    }

    // ╭─────
    // │ NOTE: |:| put code to run **BEFORE** the transfer HERE
    // ╰─────

    // ╭─────
    // │ CRITICAL
    // │ |: Main DEX swap (transaxction) transfer logic
    // ╰─────
    super._update(from, to, value);

    // ╭─────
    // │ NOTE: |:| put code to run **AFTER** the transfer HERE
    // ╰─────
    transferBuySellTakeFees(from, to, value);

    updateCirculatingSupply();

    return;
  }

  // ╭──────────────────────────────────────────────────────────────────────────────────╮
  // │ 🟥 │ CUSTOM METHODS                                                              │
  // ╰──────────────────────────────────────────────────────────────────────────────────╯

  /// @notice
  ///   📝 (override) ERC20 _transfer(..) logic in order to align with BAT tokenomics.
  /// @param sender { address }
  ///   💠 address of the sender
  /// @param recipient { address }
  ///   💠 address of the recipient
  /// @param amount { uint256 }
  ///   💠 amount to transfer
  function transferBuySellTakeFees
  (
    address sender,
    address recipient,
    uint256 amount
  )
  internal
  {
    // ╭─────
    // │ CHECK |: Preliminary check (w/ exit)
    // ┣─────
    // │ 1. Check if address is excluded from general fee
    // │ 2. Check if address is 0x0 (a void)
    // ╰─────
    if
    (
      (
        mapAddressExcluded[sender]
        || mapAddressExcluded[recipient]
      )
      ||
      (
        sender == address(0)
        || recipient == address(0)
      )
    )
    {
      // [🔘]
      if (isDebugActive) emit DebugTransactionStandard(sender, recipient);
      return;
    }

    // ╭─────
    // │ CHECK |: Buy-Action & Fee Gathering
    // ╰─────
    if (swapDetectType(sender, recipient, "buy"))
    {
      // [🔘]
      if (isDebugActive) emit DebugTransactionSwap(sender, recipient, instanceFeeLogic.numBuyFee, "buy");

      uint256 buyFeeAmount;
      uint256 priceBtaFor1Usd = calculateBitarenaPriceInStableCoinV2(instanceFeeLogic.adrBtaUsdtPool);

      unchecked
      {
        buyFeeAmount = calculateBitarenaFee(instanceFeeLogic.numBuyFee, priceBtaFor1Usd);
        if (buyFeeAmount >= amount)
        {
          buyFeeAmount = 0;
          return;
        }
      }

      // ╭─────
      // │ NOTE:
      // │ ➤ 1XY% of the buyFeeAmount is taken
      // ╰─────
      super._update(recipient, instanceFeeLogic.adrFeeDeposit, buyFeeAmount);
    }

    // ╭─────
    // │ CHECK |: Sell-Action & Fee Gathering
    // ╰─────
    if (swapDetectType(sender, recipient, "sell"))
    {
      // [🔘]
      if (isDebugActive) emit DebugTransactionSwap(sender, recipient, instanceFeeLogic.numSellFee, "sell");

      uint256 sellFeeAmount;
      uint256 priceBtaFor1Usd = calculateBitarenaPriceInStableCoinV2(instanceFeeLogic.adrBtaUsdtPool);

      unchecked
      {
        sellFeeAmount = calculateBitarenaFee(instanceFeeLogic.numSellFee, priceBtaFor1Usd);
        if (amount + sellFeeAmount >= balanceOf(sender))
        {
          sellFeeAmount = 0;
          return;
        }
      }

      // ╭─────
      // │ NOTE:
      // │ ➤ 1XY% of the sellFeeAmount is taken
      // ╰─────
      super._update(sender, instanceFeeLogic.adrFeeDeposit, sellFeeAmount);
    }

    return;
  }

  /// @notice
  ///   📝 conditions detection for swap type
  /// @param sender { address }
  ///   💠 address of the sender
  /// @param recipient { address }
  ///   💠 address of the recipient
  /// @param swapType { string }
  ///   💠 type of swap (buy/sell)
  /// @return { bool }
  ///   📤 'true' IF swap type is detected
  function swapDetectType
  (
    address sender,
    address recipient,
    string memory swapType
  )
  internal
  returns
  (
    bool
  )
  {

    // ╭──────────────────────────────────────────────────────────────────────────────────╮
    // │ 🟩 │ BUY                                                                         │
    // ┣──────────────────────────────────────────────────────────────────────────────────┫
    // │ CONDTION [0]                                                                     │
    // │  Description                                                                     │
    // │  :: Pre-Swap Detection                                                           │
    // ┣──────────────────────────────────────────────────────────────────────────────────┫
    // │ 1. 'UniversalRouter' = is 'msg.sender'                                           │
    // │ 2. 'UniversalRouter' = is 'sender/from'                                          │
    // │ 3. 'user'            = is 'recipient/to'                                         │
    // ┣──────────────────────────────────────────────────────────────────────────────────┫
    // │ CONDTION [1]                                                                     │
    // │  Description                                                                     │
    // │  :: Post-Swap Detection                                                          │
    // │  :: Typically combined with CONDTION [0], but can be a standalone                │
    // │  :: **WORKING** condition                                                        │
    // ┣──────────────────────────────────────────────────────────────────────────────────┫
    // │ 1. 'PancakeV3Pool|UniswapV3Pool' = is 'msg.sender'                               │
    // │ 2. 'PancakeV3Pool|UniswapV3Pool' = is 'sender/from'                              │
    // │ 3. 'user'                        = is 'recipient/to'                             │
    // │ 4. 'user'                        = is 'tx.origin'                                │
    // ╰──────────────────────────────────────────────────────────────────────────────────╯

    if
    (
      swapType.equal("buy")
      && instanceFeeLogic.numBuyFee != 0
      && instanceFeeLogic.buyCondition == 0
    )
    {
      string memory mapBuyKey = string.concat(Strings.toString(block.number), "_", Strings.toString(block.timestamp), "_", Strings.toString(tx.gasprice));

      // [🔘]
      if (isDebugActive) emit DebugTransactionSwapCheckpoint(mapBuyKey);

      // ╭─────
      // │ NOTE:
      // │ |: Validating the (pre-swap) 'Buy' condition
      // ╰─────
      if
      (
        msg.sender == sender
        && isUniswapV3Pool(sender)
        && mapSwapContext[tx.origin][mapBuyKey] == address(0)
      )
      {
        // [🔘]
        if (isDebugActive) emit DebugTransactionSwapCheckpoint("[checkpoint] :: Buy Condition [Step-0]");

        mapSwapContext[tx.origin][mapBuyKey] = sender;
        return false;
      }
      // ╭─────
      // │ NOTE:
      // │ |: Validating the (post-swap) 'Buy' condition
      // ╰─────
      else if
      (
        tx.origin == recipient
        && msg.sender == instanceFeeLogic.adrUniswapUniversalRouter
        && sender == instanceFeeLogic.adrUniswapUniversalRouter
        && mapSwapContext[tx.origin][mapBuyKey] != address(0)
        && !mapAdrExcludedForBuy[(mapSwapContext[tx.origin][mapBuyKey])]
      )
      {
        // [🔘]
        if (isDebugActive) emit DebugTransactionSwapCheckpoint("[checkpoint] :: Buy Condition [Step-1]");

        delete mapSwapContext[tx.origin][mapBuyKey];
        return true;
      }

      return false;
    }

    // ╭──────────────────────────────────────────────────────────────────────────────────╮
    // │ 🟥 │ SELL                                                                        │
    // ┣──────────────────────────────────────────────────────────────────────────────────┫
    // │ CONDTION [1]                                                                     │
    // │ 1. 'Permit2'                     = is 'msg.sender'                               │
    // │ 2. 'user'                        = is 'sender/from'                              │
    // │ 3. 'PancakeV3Pool|UniswapV3Pool' = is 'recipient/to'                             │
    // ╰──────────────────────────────────────────────────────────────────────────────────╯

    if
    (
      swapType.equal("sell")
      && instanceFeeLogic.numSellFee != 0
      && msg.sender == instanceFeeLogic.adrUniswapPermit2
      && !isUniswapV3Pool(sender)
      && !mapAdrExcludedForSell[recipient]
    ) return true;

    return false;
  }

  /// @notice
  ///   📝 calculates 1% of total supply of BTA Token
  /// @return { uint256 }
  ///   📤 1% of total (initial) supply
  function calcOnePercentOfTotalSupply()
  private
  view
  returns
  (
    uint256
  )
  {
    return (SUPPLY_TOTAL * 10**decimals()) * 1 / 100;
  }

  /// @notice
  ///   📝 updates the circulating supply value of BTA Token
  ///   |: based on the current balance of the non-circulating addresses
  function updateCirculatingSupply()
  private
  {
    if (totalSupply() == 0)
    {
      numCirculatingSupply = 0;
      return;
    }

    // [🐞]
    // solhint-disable no-console
    // console.log(unicode"🔹 [var] numCirculatingSupply :: %s", numCirculatingSupply);
    // console.log(unicode"🔹 [var] totalSupply() :: %s", totalSupply());
    // solhint-enable no-console

    uint256 numNonCirculatingSupply;
    uint256 numTotalSupply = totalSupply();

    // ╭─────
    // │ CHECK: |:| for same wallet address (used in testing)
    // ╰─────
    if (instanceBetarenaAddresses.adrFoundingTeam == instanceBetarenaAddresses.adrAdvisoryBoard)
    {
      numNonCirculatingSupply = balanceOf(instanceBetarenaAddresses.adrFoundingTeam);
    }
    else
    {
      numNonCirculatingSupply = balanceOf(instanceBetarenaAddresses.adrFoundingTeam);
      numNonCirculatingSupply += balanceOf(instanceBetarenaAddresses.adrAdvisoryBoard);
      numNonCirculatingSupply += balanceOf(instanceBetarenaAddresses.adrInvestors);
      numNonCirculatingSupply += balanceOf(instanceBetarenaAddresses.adrTeam);
      numNonCirculatingSupply += balanceOf(instanceBetarenaAddresses.adrParticipants);
      numNonCirculatingSupply += balanceOf(instanceBetarenaAddresses.adrMarketing);
      numNonCirculatingSupply += balanceOf(instanceBetarenaAddresses.adrLiquidity);
      numNonCirculatingSupply += balanceOf(instanceBetarenaAddresses.adrReserve);
    }

    if (numTotalSupply < numNonCirculatingSupply)
    {
      numCirculatingSupply = 0;
    }
    else
    {
      numCirculatingSupply = numTotalSupply - numNonCirculatingSupply;
    }

    // [🐞]
    // solhint-disable no-console
    // console.log(unicode"🔹 [var] numNonCirculatingSupply :: %s", numNonCirculatingSupply);
    // console.log(unicode"🔹 [var] numCirculatingSupply :: %s", numCirculatingSupply);
    // solhint-enable no-console

    return;
  }

  /// @notice
  ///   📝 checks if address is excluded from (1) general fee, (2) buy fee, (3) sell fee
  /// @param account { address }
  ///   💠 address to check
  /// @return { bool, bool, bool }
  ///   📤 'true' IF address is excluded from fee
  function isExcludedAddress
  (
    address account
  )
  external
  returns
  (
    bool,
    bool,
    bool
  )
  {
    return (mapAddressExcluded[account], mapAdrExcludedForBuy[account], mapAdrExludedForSell[account]);
  }

  /// @notice
  ///   📝 checks if address is a Uniswap V3 Pool
  /// @param account { address }
  ///   💠 address to check
  /// @return { bool }
  ///   📤 'true' IF address is a Uniswap V3 Pool
  function isUniswapV3Pool
  (
    address account
  )
  public
  view
  returns
  (
    bool
  )
  {
    return mapAddressV3Pool[account];
  }

  /// @notice
  ///   📝 calculates USD token price from main UniswapV3Pool
  /// @param _adrBtaUsdtPool { address }
  ///   💠 address of the main Uniswap/Pancake V3 Pool
  /// @return { uint256 }
  ///   📤 price of BTA token in USD
  function calculateBitarenaPriceInStableCoinV2
  (
    address _adrBtaUsdtPool
  )
  private
  nonReentrant
  returns
  (
    uint256
  )
  {
    (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(_adrBtaUsdtPool).slot0();
    address token0 = IUniswapV3Pool(_adrBtaUsdtPool).token0();
    address token1 = IUniswapV3Pool(_adrBtaUsdtPool).token1();

    // [🔘]
    if (isDebugActive) emit DebugSwapSnapshot(sqrtPriceX96);

    uint256 sqrtPriceX96Pow = 0;

    // ╭─────
    // │ NOTE:
    // │ |: Check token ordering of V3Pool, which inflicts on the final price calculation.
    // ╰─────
    if (token0 == address(this))
    {
      sqrtPriceX96Pow = uint256(sqrtPriceX96 * 10**12);
    }
    else if (token1 == address(this))
    {
      sqrtPriceX96Pow = uint256(sqrtPriceX96);
    }
    else
    {
      return 0;
    }

    uint256 price = sqrtPriceX96Pow / 2**96;
    price = price**2;
    price = price * 10**6;

    return price;
  }

  /// @notice
  ///   📝 calculate fee amount in BTA
  /// @param price { uint256 }
  ///   💠 amount to calculate fee for
  /// @param fee { uint256 }
  ///   💠 fee to be used for calculation
  /// @return { uint256 }
  ///   📤 fee amount in BTA
  function calculateBitarenaFee
  (
    uint256 fee,
    uint256 price
  )
  public
  pure
  returns
  (
    uint256
  )
  {
    return (fee * price) / 100;
  }

  // #endregion ➤ 🛠️ METHODS

  // #region ➤ 🛠️ GETTER/SETTER

  /// @notice
  ///  📝 SET |: address for EXCLUSION from fee
  /// @param account { address }
  ///   💠 address of the account to exclude
  /// @param isExcluded { bool }
  ///   💠 'true' to exclude, 'false' to include
  /// @param exclusionType { string }
  ///   💠 type of exclusion (buy/sell/general)
  function setToggleExcludeAddressFromFee
  (
    address account,
    bool isExcluded,
    string memory exclusionType
  )
  external
  onlyOwner
  {
    if (exclusionType.equal("sell"))
      mapAdrExcludedForSell[account] = isExcluded;
    else if (exclusionType.equal("buy"))
      mapAdrExcludedForBuy[account] = isExcluded;
    else if (exclusionType.equal("general"))
      mapAddressExcluded[account] = isExcluded;
    return;
  }

  /// @notice
  ///  📝 SET |: address for official Uniswap deployment smart contracts.
  /// @param _adrUniswapPermit2 { address }
  ///   💠 address of UniswapPermit2
  /// @param _adrUniswapUniversalRouter { address }
  ///   💠 address of UiswapUniversalRouter
  function setUniswapOfficialAddress
  (
    address _adrUniswapPermit2,
    address _adrUniswapUniversalRouter
  )
  external
  onlyOwner
  {
    instanceFeeLogic.adrUniswapPermit2 = _adrUniswapPermit2;
    instanceFeeLogic.adrUniswapUniversalRouter = _adrUniswapUniversalRouter;
    return;
  }

  /// @notice
  ///  📝 SET |: buy condition
  /// @param condition { uint256 }
  ///   💠 condition to set
  function setBuyCondition
  (
    uint256 condition
  )
  external
  onlyOwner
  {
    instanceFeeLogic.buyCondition = condition;
    return;
  }

  /// @notice
  ///  📝 SET |: address for new UniswapV3Pool created
  /// @param account { address }
  ///   💠 address of the Uniswap V3 Pool Created
  function setUniswapV3Pool
  (
    address account
  )
  external
  onlyOwner
  {
    mapAddressV3Pool[account] = true;
    return;
  }

  /// @notice
  ///  📝 SET |: address for Main Uniswap Fiat (pool) created
  /// @param account { address }
  ///   💠 address of the Uniswap V3 Pool Created
  function setMainLiquidtyPool
  (
    address account
  )
  external
  onlyOwner
  {
    mapAddressV3Pool[account] = true;
    instanceFeeLogic.adrBtaUsdtPool = account;
    return;
  }

  /// @notice
  ///  📝 SET |: DEX custom transaction swap fee
  /// @param fee { uint256 }
  ///   💠 buy fee expressed as USD (fiat)
  function setSwapFees
  (
    uint256 fee,
    string memory feeType
  )
  external
  onlyOwner
  {
    if (fee < 0 || fee > 250)
      revert ErrorGeneric(fee, "BTA :: fee cannot be lower than 0 or higher than 2.5 USD (=250)");
    if (feeType.equal("buy"))
      instanceFeeLogic.numBuyFee = fee;
    else if (feeType.equal("sell"))
      instanceFeeLogic.numSellFee = fee;
    return;
  }

  /// @notice
  ///  📝 SET |: Debugging flag
  /// @param _isDebugActive { bool }
  ///   💠 flag to set
  function setDebugging
  (
    bool _isDebugActive
  )
  external
  onlyOwner
  {
    isDebugActive = _isDebugActive;
    return;
  }

  // #endregion ➤ 🛠️ GETTER/SETTER

}