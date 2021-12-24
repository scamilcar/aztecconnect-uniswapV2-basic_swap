// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >0.6;

import "ds-test/test.sol";

import "./UniswapBridge.sol";

contract UniswapBridgeTest is DSTest {
    
    UniswapBridge bridge;
    AztecAsset dai;
    AztecAsset usdc;
    AztecAsset eth;

    address ROLLUP_PROCESSOR = address(this);
    address ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;  
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    function setUp() public {
        bridge = new UniswapBridge(ROLLUP_PROCESSOR, ROUTER, FACTORY);
        eth = AztecAsset(1, address(0x1), AztecAssetType.ETH);
        dai = AztecAsset(2, DAI, AztecAssetType.ERC20); 
        usdc = AztecAsset(3, USDC, AztecAssetType.ERC20);
    }

    function test_convert_ethForTokens() public {
        uint256 inputValue = 1 ether;
        AztecAsset inputAssetA = eth;
        AztecAsset outputAsset = dai;
        uint256 preBalance = IERC20.balance(bridge);
        bridge.convert(inputassetA,, outputAssetA,, inputValue,,);
        uint256 postBalance = IERC20.balance(bridge);






    }


}
