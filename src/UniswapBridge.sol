// SPDX-License-Identifier: GPL-2.0-only
// Copyright 2020 Spilsbury Holdings Ltd
pragma solidity >0.6;
pragma experimental ABIEncoderV2;

import "./libraries/SafeMath.sol";
import "./interfaces/IERC20.sol";


import "./interfaces/uniswap/IUniswapV2Router02.sol";
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
  constructor(address _rollupProcessor, address _router, address _factory) {
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

    if (
      inputAssetA.assetType == Types.AztecAssetType.ETH &&
      outputAssetA.assetType == Types.AztecAssetType.ERC20
    ) {
      require(factory.getPair(weth, outputAssetA.erc20Address) != address(0), "UniswapBridge: INVALID_PAIR");
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
      require(factory.getPair(inputAssetA.erc20Address, weth) != address(0), "UniswapBridge: INVALID_PAIR");
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

      
    } else if (
      inputAssetA.assetType == Types.AztecAssetType.ERC20 &&
      outputAssetA.assetType == Types.AztecAssetType.ERC20
    ) {
      require(factory.getPair(inputAssetA.erc20Address, outputAssetA.erc20Address) != address(0), "UniswapBridge: INVALID_PAIR");
      address[] memory path = new address[](3);
      path[0] = inputAssetA.erc20Address;
      path[1] = weth;
      path[2] = outputAssetA.erc20Address;
      require(
        IERC20(inputAssetA.erc20Address).approve(address(router), inputValue),
        "UniswapBridge: APPROVE_FAILED"
      );
      amounts = router.swapExactTokensForTokens(
        inputValue,
        0,
        path,
        rollupProcessor,
        deadline
      );
      outputValueA = amounts[2];
    } else {
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


