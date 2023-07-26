// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*  
* @title : DSCEngine
* @author : Ujjwal Thakur
* Characterstics: Pegged to USD, Algorithmic,Exogenous
* Our system is always  be "overCollateralized"
**/

contract DSCEngine is ReentrancyGuard {
    ////////////////////////////////
    // errors //
    ////////////////////////////////
    error DSCEngine__MoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();

    ////////////////////////////////
    // State Variables //
    ////////////////////////////////

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address)
    DecentralizedStableCoin private immutable i_dsc;

    ////////////////////////////////
    // State Events //
    ////////////////////////////////

    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    ////////////////////////////////
    // Modifiers //
    ////////////////////////////////
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__MoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__NotAllowedToken();
        }
        _;
    }

    ////////////////////////////////
    // functions //
    ////////////////////////////////

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    ////////////////////////////////
    // External Functions //
    ////////////////////////////////

    function depositCollateralAndMintDsc() external {}

    /* 
    * @note following CEI
    * @param collateralTokenAddress is address of token to deposit as collateral
    * @param colllateralTokenAmount is a amount of token to be  deposited as a collateral
    */

    function depositCollateral(address collateralTokenAddress, uint256 collateralTokenAmount)
        external
        moreThanZero(collateralTokenAmount)
        isAllowedToken(collateralTokenAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][collateralTokenAddress] += collateralTokenAmount;
        emit CollateralDeposited(msg.sender, collateralTokenAddress, collateralTokenAmount);
        /*
          Here we are creating a instance of contarct using the interface and contract's address
         When we do so we can interact with the contract's function that are defined in the interface
        IERC20(collateralTokenAddress).transferFrom(msg.sender, address(this), collateralTokenAmount) => contract.transferFrom(msg.sender, address(this
        */
        bool success = IERC20(collateralTokenAddress).transferFrom(msg.sender, address(this), collateralTokenAmount);
        
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
