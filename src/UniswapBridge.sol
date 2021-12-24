// SPDX-License-Identifier: GPL-2.0-only
// Copyright 2020 Spilsbury Holdings Ltd
pragma solidity >0.6;
pragma experimental ABIEncoderV2;

import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { UniswapV2Library } from "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import { IUniswapV2Router02 } from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./interfaces/uniswap/IUniswapV2Factory.sol";

import "./interfaces/IDefiBridge.sol";
import "./libraries/Types.sol";

// import 'hardhat/console.sol';

contract UniswapBridge is IDefiBridge {
  using SafeMath for uint256;

  address public immutable rollupProcessor;
  address public weth;

  IUniswapV2Router02 router;
  IUniswapV2Factory factory;
  // Added '_factory' to be able to call 'factory.getPair(address,address)' to check if the pair exists.
  constructor(address _rollupProcessor, address _router, address _factory) public {
    rollupProcessor = _rollupProcessor;
    router = IUniswapV2Router02(_router);
    factory = IUniswapV2Factory(_factory);
    weth = router.WETH();
  }

  receive() external payable {}

  function convert(
    Types.AztecAsset calldata inputAssetA,
    Types.AztecAsset calldata,
    Types.AztecAsset calldata outputAssetA,
    Types.AztecAsset calldata,
    uint256 inputValue,
    uint256,
    uint64
  )
    external
    payable
    override
    returns (
      uint256 outputValueA,
      uint256,
      bool isAsync
    )
  {
    require(msg.sender == rollupProcessor, "UniswapBridge: INVALID_CALLER");
    isAsync = false;
    uint256[] memory amounts;
    uint256 deadline = block.timestamp;
    // CHANGED - This should check the pair exists on UNISWAP instead of blindly trying to swap.
    if (inputAssetA.assetType == Types.AztecAssetsTypes.ETH || outputAssetA.assetType == Types.AztecAsssetsTypes.ETH) {
      require(factory.getPair(weth, ouputAssetA.erc20address) != address(0), "UniswapBridge: INVALID_PAIR");
    } else {
      require(factory.getPair(inputAssetA.erc20address, ouputAssetA.erc20address) != address(0), "UniswapBridge: INVALID_PAIR");
    }
    if (
      inputAssetA.assetType == Types.AztecAssetType.ETH &&
      outputAssetA.assetType == Types.AztecAssetType.ERC20
    ) {
      address[] memory path = new address[](2);
      path[0] = weth;
      path[1] = outputAssetA.erc20Address;
      amounts = router.swapExactETHForTokens{ value: inputValue }(
        0,
        path,
        rollupProcessor,
        deadline
      );
      outputValueA = amounts[1];
    } else if (
      inputAssetA.assetType == Types.AztecAssetType.ERC20 &&
      outputAssetA.assetType == Types.AztecAssetType.ETH
    ) {
      address[] memory path = new address[](2);
      path[0] = inputAssetA.erc20Address;
      path[1] = weth;
      require(
        IERC20(inputAssetA.erc20Address).approve(address(router), inputValue),
        "UniswapBridge: APPROVE_FAILED"
      );
      amounts = router.swapExactTokensForETH(
        inputValue,
        0,
        path,
        rollupProcessor,
        deadline
      );
      outputValueA = amounts[1];
    } else {
      // CHANGED what about swapping tokens?
      address[] memory path = new address[](3);
      path[0] = inputAssetA.erc20address;
      path[1] = weth;
      path[2] = outputAssetA.erc20address;
      require(
        IERC20(inputAssetA.erc20address).approve(router, inputValue),
        "UniswapBridge: APPROVE_FAILED"
      );
      amounts = router.swapExactTokensForTokens(
        inputValue,
        0,
        path,
        rollupProcessor,
        deadline
      );
      outputValueA = amounts[1];
      revert("UniswapBridge: INCOMPATIBLE_ASSET_PAIR");
    }
  }

  function canFinalise(
    uint256 /*interactionNonce*/
  ) external view override returns (bool) {
    return false;
  }

  function finalise(
    Types.AztecAsset calldata,
    Types.AztecAsset calldata,
    Types.AztecAsset calldata,
    Types.AztecAsset calldata,
    uint256,
    uint64
  ) external payable override returns (uint256, uint256) {
    require(false);
  }
}


