// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

// https://github.com/OpenZeppelin/openzeppelin-contracts/issues/2580
// https://raw.githubusercontent.com/ethereum/solc-bin/gh-pages/bin/list.json
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

  // #region ➤ 📌 VARIABLES

  /// @notice
  ///   📝 ERC-20 Token initial supply
  uint256 public constant SUPPLY_TOTAL = 21000000;
  /// @notice
  ///   📝 Buy Fee, expressed in dollars ($) as 0.0 (1dp)
  uint256 public numBuyFee;
  /// @notice
  ///   📝 Sell Fee, expressed in dollars ($) as 0.0 (1dp)
  uint256 public numSellFee;
  /// @notice
  ///   📝 Circulating Supply of BTA Token
  uint256 public numCirculatingSupply;
  /// @notice
  ///   📝 Main BTA liquidity address (usdt)
  address public adrBtaUsdtPool;
  /// @notice
  ///   📝 Address of the PancakeSwap Permit2
  address public adrPancakeSwapPermit2;
  /// @notice
  ///   📝 Address of the Fee Deposit
  address public adrFeeDeposit;
  /// @notice
  ///   📝 Mapping of Official Bitarena Addresses that are Excluded from Fee
  mapping (address addressExcluded => bool isExcluded) private mapAddressExcluded;
  /// @notice
  ///   📝 Mapping of Official Bitarena Addresses of (V3) Liquidity Pools
  mapping (address addressV3Pool => bool isPool) private mapAddressV3Pool;

  /// @notice
  ///   📝 Address of Official Team
  address public adrFoundingTeam;
  /// @notice
  ///   📝 Address of Official Team
  address public adrAdvisoryBoard;
  /// @notice
  ///   📝 Address of Official Team
  address public adrInvestors;
  /// @notice
  ///   📝 Address of Official Team
  address public adrTeam;
  /// @notice
  ///   📝 Address of Official Team
  address public adrParticipants;
  /// @notice
  ///   📝 Address of Official Team
  address public adrMarketing;
  /// @notice
  ///   📝 Address of Official Team
  address public adrLiquidity;
  /// @notice
  ///   📝 Address of Official Team
  address public adrReserve;

  // #endregion ➤ 📌 VARIABLES

  // #region ➤ 📣 EVENTS

  /// @notice
  ///   📝 Debugging event for WithdrawETH
  // event DebugFunctionWithdrawETH  (address indexed sender, uint256 amount);
  /// @notice
  ///   📝 Debugging event for Transaction
  // event DebugTransaction          (address indexed sender, address indexed recipient, uint256 amount, address indexed msgSender);
  /// @notice
  ///   📝 Debugging event for Transaction (Standard)
  // event DebugTransactionStandard  (address indexed sender, address indexed recipient, uint256 amount);
  /// @notice
  ///   📝 Debugging event for Transaction (Buy)
  // event DebugTransactionBuy       (address indexed sender, address indexed recipient, uint256 amount, uint256 buyFeeAmount);
  /// @notice
  ///   📝 Debugging event for Transaction (Sell)
  // event DebugTransactionSell      (address indexed sender, address indexed recipient, uint256 amount, uint256 sellFeeAmount);
  /// @notice
  ///   📝 Debugging event for Swap Snapshot
  // event DebugSwapSnapshot         (uint160 sqrtPriceX96);
  /// @notice
  ///   📝 Error event for Generic Error
  error ErrorGeneric              (uint256 value, string message);

  // #endregion ➤ 📣 EVENTS

  /// @notice
  ///   📝 BitarenaToken
  constructor
  (
    string memory _name,
    string memory _symbol,
    address _adrFeeAddress,
    address _adrFoundingTeam,
    address _adrAdvisoryBoard,
    address _adrInvestors,
    address _adrTeam,
    address _adrParticipants,
    address _adrMarketing,
    address _adrLiquidity,
    address _adrReserve,
    address _adrPancakeSwapPermit2
  )
  ERC20(_name, _symbol)
  ERC20Permit(_name)
  Ownable(msg.sender)
  {
    adrFeeDeposit         = _adrFeeAddress;
    adrFoundingTeam       = _adrFoundingTeam;
    adrAdvisoryBoard      = _adrAdvisoryBoard;
    adrInvestors          = _adrInvestors;
    adrTeam               = _adrTeam;
    adrParticipants       = _adrParticipants;
    adrMarketing          = _adrMarketing;
    adrLiquidity          = _adrLiquidity;
    adrReserve            = _adrReserve;
    adrPancakeSwapPermit2 = _adrPancakeSwapPermit2;

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
    // console.log(unicode"🔹 [var] _adrPancakeSwapPermit2 :: %s", _adrPancakeSwapPermit2);
    // console.log(unicode"🔹 [var] address(this) :: %s", address(this));
    // solhint-enable no-console

    // ╭──────────────────────────────────────────────────────────────────────────────────╮
    // │ 🟥 │ MAIN INTIALIZER LOGIC                                                       │
    // ╰──────────────────────────────────────────────────────────────────────────────────╯

    uint256 _onePercent = calcOnePercentOfTotalSupply();

    _mint(adrFoundingTeam,  (_onePercent * 5));
    _mint(adrAdvisoryBoard, (_onePercent * 2));
    _mint(adrInvestors,     (_onePercent * 4));
    _mint(adrTeam,          (_onePercent * 5));
    _mint(adrParticipants,  (_onePercent * 10));
    _mint(adrMarketing,     (_onePercent * 10));
    _mint(adrLiquidity,     (_onePercent * 60));
    _mint(adrReserve,       (_onePercent * 4));

    // Causes Error:
    // ProviderError: Error: VM Exception while processing transaction: reverted with panic code 0x11 (Arithmetic operation overflowed outside of an unchecked block)
    updateCirculatingSupply();

    mapAddressExcluded[owner()]          = true;
    mapAddressExcluded[address(this)]    = true;
    mapAddressExcluded[adrFoundingTeam]  = true;
    mapAddressExcluded[adrAdvisoryBoard] = true;
    mapAddressExcluded[adrInvestors]     = true;
    mapAddressExcluded[adrTeam]          = true;
    mapAddressExcluded[adrParticipants]  = true;
    mapAddressExcluded[adrMarketing]     = true;
    mapAddressExcluded[adrLiquidity]     = true;
    mapAddressExcluded[adrReserve]       = true;

    numBuyFee  = 100;
    numSellFee = 50;

    return;
  }

  // #region ➤ 🛠️ METHODS

  // ╭──────────────────────────────────────────────────────────────────────────────────╮
  // │ 💠 │ MISCELLENOUS                                                                │
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
    // emit DebugFunctionWithdrawETH(owner(), amount);
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
  internal override
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
    // emit DebugTransaction(from, to, value, msg.sender);

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
    transferBuySellTakeFees(from, to);

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
  function transferBuySellTakeFees
  (
    address sender,
    address recipient
  )
  internal
  {
    // [🐞]
    // solhint-disable no-console
    // console.log(unicode"🚏 [checkpoint] :: transferBuySellTakeFees(..)");
    // console.log(unicode"🔹 [var] sender :: %s", sender);
    // console.log(unicode"🔹 [var] recipient :: %s", recipient);
    // console.log(unicode"🔹 [var] amount :: %s", amount);
    // solhint-enable no-console

    bool isUniswapV3PoolSender = isUniswapV3Pool(sender);
    bool isUniswapV3PoolRecipient = isUniswapV3Pool(recipient);

    // ╭─────
    // │ CHECK |: Preliminary check (exit)
    // ┣─────
    // │ 1. Check for valid Uniswap V3 Pool
    // │ 2. Check if address is excluded
    // │ 3. Check if address is 0x0 (void)
    // ╰─────
    if
    (
      (
        !isUniswapV3PoolSender
        && !isUniswapV3PoolRecipient
      )
      ||
      (
        isExcludedAddress(sender)
        || isExcludedAddress(recipient)
      )
      ||
      (
        sender == address(0)
        || recipient == address(0)
      )
    )
    {
      // [🔘]
      // emit DebugTransactionStandard(sender, recipient, amount);

      // [🐞]
      // solhint-disable-next-line
      // console.log(unicode"🚏 [checkpoint] :: Not Valid Fee Transaction Deduction");

      return;
    }

    // ╭─────
    // │ CHECK |:
    // │ Origin Address of UniSwapV3Pool, as only one of the two addresses
    // │ (sender/recipient) can be a UniswapV3Pool at any given time,
    // │ wether a buy or sell action is being executed.
    // ╰─────
    uint8 originAddressIsUniswapV3 = isUniswapV3PoolSender ? 1 : 0;

    // ╭─────
    // │ CHECK |: Buy-Action
    // ┣─────
    // │ 1. 'PancakeV3Pool|UniswapV3Pool' = is 'msg.sender'
    // │ 2. 'PancakeV3Pool|UniswapV3Pool' = is 'sender/from'
    // │ 3. 'user'                        = is 'recipient/to'
    // ╰─────
    if
    (
      msg.sender == sender
      && originAddressIsUniswapV3 == 1
      // ╭─────
      // │ NOTE: |:| apply fees only if 'numBuyFee' is set to (not) != 0;
      // ╰─────
      && numBuyFee != 0
    )
    {
      // [🔘]
      // emit DebugTransactionBuy(sender, recipient, amount, numBuyFee);

      uint256 buyFeeAmount;
      uint256 priceBtaFor1Usd = calculateBitarenaPriceInStableCoinV2(adrBtaUsdtPool);

      unchecked
      {
        buyFeeAmount = calculateBitarenaFee(numBuyFee, priceBtaFor1Usd);
      }

      // [🐞]
      // solhint-disable-next-line
      // console.log(unicode"🚏 [checkpoint] :: Buy Executed");

      // ╭─────
      // │ NOTE:
      // │ ➤ 1XY% of the buyFeeAmount is taken
      // ╰─────
      super._update(recipient, adrFeeDeposit, buyFeeAmount);
    }

    // ╭─────
    // │ CHECK |: Sell-Action
    // ┣─────
    // │ 1. 'Permit2'                     = is 'msg.sender'
    // │ 2. 'user'                        = is 'sender/from'
    // │ 3. 'PancakeV3Pool|UniswapV3Pool' = is 'recipient/to'
    // ╰─────
    if
    (
      msg.sender == adrPancakeSwapPermit2
      && originAddressIsUniswapV3 == 0
      // ╭─────
      // │ NOTE: |:| apply fees only if 'numSellFee' is set to (not) != 0;
      // ╰─────
      && numSellFee != 0
    )
    {
      // [🔘]
      // emit DebugTransactionSell(sender, recipient, amount, numSellFee);

      uint256 sellFeeAmount;
      uint256 priceBtaFor1Usd = calculateBitarenaPriceInStableCoinV2(adrBtaUsdtPool);

      unchecked
      {
        sellFeeAmount = calculateBitarenaFee(numSellFee, priceBtaFor1Usd);
      }

      // [🐞]
      // solhint-disable-next-line
      // console.log(unicode"🚏 [checkpoint] :: Sell Executed");

      // ╭─────
      // │ NOTE:
      // │ ➤ 1XY% of the sellFeeAmount is taken
      // ╰─────
      super._update(sender, adrFeeDeposit, sellFeeAmount);
    }

    return;
  }

  /// @notice
  ///   📝 calculates 1% of total supply of BTA Token
  /// @return { uint256 }
  ///   📤 1% of total (initial) supply
  function calcOnePercentOfTotalSupply()
  private view
  returns (uint256)
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
    if (adrFoundingTeam == adrAdvisoryBoard)
    {
      numNonCirculatingSupply = balanceOf(adrFoundingTeam);
    }
    else
    {
      numNonCirculatingSupply = balanceOf(adrFoundingTeam);
      numNonCirculatingSupply += balanceOf(adrAdvisoryBoard);
      numNonCirculatingSupply += balanceOf(adrInvestors);
      numNonCirculatingSupply += balanceOf(adrTeam);
      numNonCirculatingSupply += balanceOf(adrParticipants);
      numNonCirculatingSupply += balanceOf(adrMarketing);
      numNonCirculatingSupply += balanceOf(adrLiquidity);
      numNonCirculatingSupply += balanceOf(adrReserve);
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
  ///   📝 checks if address is excluded
  /// @param account { address }
  ///   💠 address to check
  /// @return { bool }
  ///   📤 'true' IF address is excluded from fee
  function isExcludedAddress
  (
    address account
  )
  public view
  returns (bool)
  {
    return mapAddressExcluded[account];
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
  public view
  returns (bool)
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
    // emit DebugSwapSnapshot(sqrtPriceX96);

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
  public pure
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
  function setToggleExcludeAddressFromFee
  (
    address account,
    bool isExcluded
  )
  external
  onlyOwner
  {
    mapAddressExcluded[account] = isExcluded;
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
    adrBtaUsdtPool = account;
    return;
  }

  /// @notice
  ///  📝 SET |: buy fee
  /// @param fee { uint256 }
  ///   💠 buy fee expressed as USD (fiat)
  function setBuyFee
  (
    uint256 fee
  )
  external
  onlyOwner
  {
    if (fee < 0 || fee > 250) revert ErrorGeneric(fee, "BTA :: buy fee cannot be lower than 0 or higher than 2.5 USD (=250)");
    numBuyFee = fee;
    return;
  }

  /// @notice
  ///  📝 SET |: sell fee
  /// @param fee { uint256 }
  ///   💠 sell fee expressed as USD (fiat)
  function setSellFee
  (
    uint256 fee
  )
  external
  onlyOwner
  {
    if (fee < 0 || fee > 250) revert ErrorGeneric(fee, "BTA :: sell fee cannot be lower than 0 or higher than 2.5 USD (=250)");
    numSellFee = fee;
    return;
  }

  // #endregion ➤ 🛠️ GETTER/SETTER

}