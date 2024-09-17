// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity 0.8.24;

import "hardhat/console.sol"; import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol"; import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol"; import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol"; import "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Pool.sol";

contract BitarenaToken is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, Ownable2StepUpgradeable, ERC20PermitUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {

  uint256 public lockedAmount; uint256 public constant SUPPLY_TOTAL = 21000000; uint256 public numBuyFee; uint256 public numSellFee; uint256 public numMaxTransactionAmount; uint256 public numCirculatingSupply; address public adrBtaUsdtPool; address public adrPancakeSwapPermit2; address public adrFeeDeposit; mapping (address => bool) private mapAddressExcluded; mapping (address => bool) private mapAddressV3Pool;
  address public adrFoundingTeam; address public adrAdvisoryBoard; address public adrInvestors; address public adrTeam; address public adrParticipants; address public adrMarketing; address public adrLiquidity; address public adrReserve;
  event DebugAmount (uint256 amount); event DebugAddress (address indexed account); event DebugTransaction (address indexed sender, address indexed recipient, uint256 amount, address indexed msgSender); event DebugTransactionStandard (address indexed sender, address indexed recipient, uint256 amount); event DebugTransactionBuy (address indexed sender, address indexed recipient, uint256 amount, uint256 buyFeeAmount); event DebugTransactionSell (address indexed sender, address indexed recipient, uint256 amount, uint256 sellFeeAmount);
  error ErrorGeneric(uint256 value, string message);

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() { _disableInitializers(); }

  receive() external payable
  {
    lockedAmount += msg.value;
    return;
  }

  fallback() external payable {}

  function withdraw() public onlyOwner() {
    address payable recipient = payable(owner());
    recipient.transfer(address(this).balance);
    return;
  }

  function initialize ( string memory _name, string memory _symbol, address _adrFeeAddress, address _adrFoundingTeam, address _adrAdvisoryBoard, address _adrInvestors, address _adrTeam, address _adrParticipants, address _adrMarketing, address _adrLiquidity, address _adrReserve, address _adrPancakeSwapPermit2
  )
  public initializer
  {
    adrFeeDeposit       = _adrFeeAddress; adrFoundingTeam     = _adrFoundingTeam; adrAdvisoryBoard    = _adrAdvisoryBoard; adrInvestors        = _adrInvestors; adrTeam             = _adrTeam; adrParticipants     = _adrParticipants; adrMarketing        = _adrMarketing; adrLiquidity        = _adrLiquidity; adrReserve          = _adrReserve; adrPancakeSwapPermit2 = _adrPancakeSwapPermit2;  // [🐞]

    __ERC20_init(_name, _symbol); __ERC20Burnable_init(); __ERC20Pausable_init(); __Ownable_init(msg.sender); __ERC20Permit_init(_name); __UUPSUpgradeable_init(); __ReentrancyGuard_init(); uint256 _onePercent = calcOnePercentOfTotalSupply();
    _mint(adrFoundingTeam,  (_onePercent * 5));   _mint(adrAdvisoryBoard, (_onePercent * 2));   _mint(adrInvestors,     (_onePercent * 4));  _mint(adrTeam,          (_onePercent * 5));    _mint(adrParticipants,  (_onePercent * 10));    _mint(adrMarketing,     (_onePercent * 10));    _mint(adrLiquidity,     (_onePercent * 60));    _mint(adrReserve,       (_onePercent * 4));

    // Causes Error:
    // ProviderError: Error: VM Exception while processing transaction: reverted with panic code 0x11 (Arithmetic operation overflowed outside of an unchecked block)
    updateCirculatingSupply();

    mapAddressExcluded[owner()] = true; mapAddressExcluded[address(this)]    = true; mapAddressExcluded[adrFoundingTeam]  = true; mapAddressExcluded[adrAdvisoryBoard] = true; mapAddressExcluded[adrInvestors]     = true; mapAddressExcluded[adrTeam]          = true; mapAddressExcluded[adrParticipants]  = true; mapAddressExcluded[adrMarketing]     = true; mapAddressExcluded[adrLiquidity]     = true; mapAddressExcluded[adrReserve]       = true;

    numBuyFee  = 100; numSellFee = 50; numMaxTransactionAmount = 100;

    return;
  }

  function pause () public onlyOwner { _pause(); }
  function unpause () public onlyOwner { _unpause(); }
  function mint (address to, uint256 amount) public onlyOwner { _mint(to, amount); }
  function _authorizeUpgrade (address newImplementation) internal onlyOwner override { /* solhint-disable-line no-empty-blocks */ }
  function _update ( address from, address to, uint256 value ) internal override ( ERC20Upgradeable, ERC20PausableUpgradeable )
  {
    emit DebugTransaction(from, to, value, msg.sender);
    uint256 _value = transferBuySellTakeFees(from, to, value);
    super._update(from, to, _value);
    updateCirculatingSupply();
    return;
  }

  function transferBuySellTakeFees
  (
    address sender,
    address recipient,
    uint256 amount
  )
  internal
  returns (uint256)
  {
    uint256 sendAmount = amount;

    bool isUniswapV3PoolSender = isUniswapV3Pool(sender); bool isUniswapV3PoolRecipient = isUniswapV3Pool(recipient);

    if ( (!isUniswapV3PoolSender && !isUniswapV3PoolRecipient) || (isExcludedAddress(sender) || isExcludedAddress(recipient)) || (sender == address(0) || recipient == address(0)))
    {
      emit DebugTransactionStandard(sender, recipient, amount);
      return sendAmount;
    }

    uint8 originAddressIsUniswapV3 = isUniswapV3PoolSender ? 1 : 0;

    if(msg.sender == sender && originAddressIsUniswapV3 == 1 && numBuyFee != 0)
    {
      emit DebugTransactionBuy(sender, recipient, amount, numBuyFee);
      uint256 buyFeeAmount; uint256 priceBtaFor1Usd = calculateBitarenaPriceInStableCoinV2(adrBtaUsdtPool);
      unchecked
      {
        buyFeeAmount = calculateBitarenaFee(numBuyFee, priceBtaFor1Usd);
        sendAmount = amount - buyFeeAmount;
        require(amount == sendAmount + buyFeeAmount, "BTA :: transferBuySellTakeFees(..) :: Buy value is invalid");
      }
      super._update(sender, adrFeeDeposit, buyFeeAmount);
    }

    if
    (
      msg.sender == adrPancakeSwapPermit2
      && originAddressIsUniswapV3 == 0
      && numSellFee != 0
    )
    {
      emit DebugTransactionSell(sender, recipient, amount, numSellFee);

      if (sendAmount > ((numCirculatingSupply * numMaxTransactionAmount) / 100)) revert ErrorGeneric(sendAmount, "BTA :: Sell amount exceeds anti-whale threshold");

      uint256 sellFeeAmount;
      uint256 priceBtaFor1Usd = calculateBitarenaPriceInStableCoinV2(adrBtaUsdtPool);

      unchecked
      {
        sellFeeAmount = calculateBitarenaFee(numSellFee, priceBtaFor1Usd);
      }

      super._update(sender, adrFeeDeposit, sellFeeAmount);
    }

    return sendAmount;
  }

  function calcOnePercentOfTotalSupply() public view returns (uint256) { return (SUPPLY_TOTAL * 10**decimals()) * 1 / 100; }

  function updateCirculatingSupply() private
  {
    if (totalSupply() == 0) { numCirculatingSupply = 0; return; }

    uint256 numNonCirculatingSupply = 0; uint256 numTotalSupply = totalSupply();

    if (adrFoundingTeam == adrAdvisoryBoard) { numNonCirculatingSupply += balanceOf(adrFoundingTeam); }
    else { numNonCirculatingSupply += balanceOf(adrFoundingTeam); numNonCirculatingSupply += balanceOf(adrAdvisoryBoard); numNonCirculatingSupply += balanceOf(adrInvestors); numNonCirculatingSupply += balanceOf(adrTeam); numNonCirculatingSupply += balanceOf(adrParticipants); numNonCirculatingSupply += balanceOf(adrMarketing); numNonCirculatingSupply += balanceOf(adrLiquidity); numNonCirculatingSupply += balanceOf(adrReserve);
    }

    if (numTotalSupply < numNonCirculatingSupply) { numCirculatingSupply = 0; }
    else { numCirculatingSupply = numTotalSupply - numNonCirculatingSupply; }

    return;
  }

  function isExcludedAddress ( address account ) public view returns (bool) { return mapAddressExcluded[account]; }
  function isUniswapV3Pool (address account) public view returns (bool) { return mapAddressV3Pool[account]; }
  function calculateBitarenaPriceInStableCoinV2 ( address _adrBtaUsdtPool ) public nonReentrant returns ( uint256 ) {
    (uint160 sqrtPriceX96, , , , , , ) = IPancakeV3Pool(_adrBtaUsdtPool).slot0(); uint256 sqrtPriceX96Pow = uint256(sqrtPriceX96 * 10**12); uint256 priceFromSqrtX96 = sqrtPriceX96Pow / 2**96; priceFromSqrtX96 = priceFromSqrtX96**2;
    return priceFromSqrtX96 / 1000000;
  }

  function calculateBitarenaFee ( uint256 fee, uint256 price ) public pure returns ( uint256 ) { return (fee * price) / 100; }
  function setToggleExcludeAddressFromFee ( address account, bool isExcluded ) external onlyOwner { mapAddressExcluded[account] = isExcluded; return; }
  function setUniswapV3Pool ( address account ) external onlyOwner { mapAddressV3Pool[account] = true; return; }
  function setMainLiquidtyPool ( address account ) external onlyOwner { adrBtaUsdtPool = account; return; }
  function setAntiWhaleCirculationThresholdFee ( uint256 _supplyPercentage ) external onlyOwner
  {
    if (_supplyPercentage <= 20) revert ErrorGeneric(_supplyPercentage, "BTA :: anti-whale threshold cannot be lower than 0.2%");
    numMaxTransactionAmount = _supplyPercentage;
    return;
  }

  function setBuyFee ( uint256 fee ) external onlyOwner
  {
    if (fee <= 0 || fee >= 250) revert ErrorGeneric(fee, "BTA :: buy fee cannot be lower than 0 or higher than 2.5 USD (=250)");
    numBuyFee = fee;
    return;
  }

  function setSellFee ( uint256 fee ) external onlyOwner
  {
    if (fee <= 0 || fee >= 250) revert ErrorGeneric(fee, "BTA :: sell fee cannot be lower than 0 or higher than 2.5 USD (=250)");
    numSellFee = fee;
    return;
  }

}