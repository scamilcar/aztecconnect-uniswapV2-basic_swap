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

    if (
      inputAssetA.assetType == Types.AztecAssetType.ETH &&
      outputAssetA.assetType == Types.AztecAssetType.ERC20
    ) {
      outputValueA = _swapEthForTokens(inputValue, outputAssetA.erc20Address);

    } else if (
      inputAssetA.assetType == Types.AztecAssetType.ERC20 &&
      outputAssetA.assetType == Types.AztecAssetType.ETH
    ) {
      outputValueA = _swapTokensForEth(inputValue, inputAssetA.erc20Address);

    } else if (
      inputAssetA.assetType == Types.AztecAssetType.ERC20 &&
      outputAssetA.assetType == Types.AztecAssetType.ERC20
    ) { 
      outputValueA = _swapTokensForTokens(inputValue, inputAssetA.erc20Address, outputAssetA.erc20Address);

    } else {
      revert("UniswapBridge: INCOMPATIBLE_ASSET_PAIR");
    }

}

  function _swapEthForTokens(
    uint256 _inputValue,
    address _outputAsset
    ) private returns (uint256 outputValueA) {

    require(factory.getPair(weth, _outputAsset) != address(0), "UniswapBridge: INVALID_PAIR");
    uint256[] memory amounts;
    address[] memory path = new address[](2);
    path[0] = weth;
    path[1] = _outputAsset;
    amounts = router.swapExactETHForTokens{ value: _inputValue }(
      0,
      path,
      rollupProcessor,
      block.timestamp
    );
    outputValueA = amounts[1];
  }

  
  function _swapTokensForEth(
    uint256 _inputValue,
    address _inputAsset
    ) private returns (uint256 outputValueA) {

    require(factory.getPair(weth, _inputAsset) != address(0), "UniswapBridge: INVALID_PAIR");
    uint256[] memory amounts;
    address[] memory path = new address[](2);
    path[0] = _inputAsset;
    path[1] = weth;
    require(
        IERC20(_inputAsset).approve(address(router), _inputValue),
        "UniswapBridge: APPROVE_FAILED"
      );
    amounts = router.swapExactTokensForETH(
      _inputValue,
      0,
      path,
      rollupProcessor,
      block.timestamp
    );
    outputValueA = amounts[1];
  }

  // Method only working for 2 ERC20s whose pair exists  
  // and for ERC20s whose pair does not exist but which are both paired with ETH.
  function _swapTokensForTokens(
    uint256 _inputValue,
    address _inputAsset,
    address _outputAsset
    ) private returns (uint256 outputValueA) {

    uint256[] memory amounts;

    if (factory.getPair(_inputAsset, _outputAsset) != address(0)) {
      address[] memory path = new address[](2);
      path[0] = _inputAsset;
      path[1] = _outputAsset;
      require(
        IERC20(_inputAsset).approve(address(router), _inputValue),
        "UniswapBridge: APPROVE_FAILED"
      );
      amounts = router.swapExactTokensForTokens(
        _inputValue,
        0,
        path,
        rollupProcessor,
        block.timestamp
      );
      outputValueA = amounts[1];


      } else if (
        factory.getPair(weth, _inputAsset) != address(0) &&
        factory.getPair(weth, _outputAsset) != address(0)
      ) {
        address[] memory path = new address[](3);
        path[0] = _inputAsset;
        path[1] = weth;
        path[2] = _outputAsset;
        require(
          IERC20(_inputAsset).approve(address(router), _inputValue),
          "UniswapBridge: APPROVE_FAILED"
        );
        amounts = router.swapExactTokensForTokens(
          _inputValue,
          0,
          path,
          rollupProcessor,
          block.timestamp
        );
        outputValueA = amounts[2];

      } else {
        revert("UniswapBridge: INVALID_PAIR");
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


