// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >0.6;

import "../lib/ds-test/src/test.sol";
import "./UniswapBridge.sol";

import "./libraries/Types.sol";

import "./interfaces/IERC20.sol";

contract UniswapBridgeTest is DSTest {
    
    UniswapBridge bridge;
    Types.AztecAsset dai;
    Types.AztecAsset usdc;
    Types.AztecAsset eth;
    Types.AztecAsset inputAssetB;
    Types.AztecAsset outputAssetB;

    address ROLLUP_PROCESSOR = address(this);
    address ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;  
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    function setUp() public {
        bridge = new UniswapBridge(ROLLUP_PROCESSOR, ROUTER, FACTORY);
        eth = Types.AztecAsset(1, address(0x1), Types.AztecAssetType.ETH);
        dai = Types.AztecAsset(2, DAI, Types.AztecAssetType.ERC20); 
        usdc = Types.AztecAsset(3, USDC, Types.AztecAssetType.ERC20);
        inputAssetB = Types.AztecAsset(4, address(0x2), Types.AztecAssetType.ERC20);
        outputAssetB = Types.AztecAsset(5, address(0x3), Types.AztecAssetType.ERC20);

    }

    function test_convert_ethForTokens() public {
        (bool sent, ) = address(bridge).call{value: 1 ether}("u fool");
        require(sent, "Failed to send Ether");
        uint256 inputValue = 1 ether;
        Types.AztecAsset memory inputAssetA = eth;
        Types.AztecAsset memory outputAssetA = dai;
        uint256 preBalanceInputAssetA = address(bridge).balance;
        uint256 preBalanceOutputAssetA = IERC20(outputAssetA.erc20Address).balanceOf(address(bridge));
        (uint outputValueA,,) = bridge.convert(
            inputAssetA,
            inputAssetB,
            outputAssetA,
            outputAssetB,
            inputValue,
            0,
            0
            );
        uint256 postBalanceInputAssetA = address(bridge).balance;
        uint256 postBalanceOutputAssetA = IERC20(outputAssetA.erc20Address).balanceOf(address(bridge));
        assertEq(preBalanceInputAssetA - inputValue, postBalanceInputAssetA);
        assertEq(preBalanceOutputAssetA + outputValueA, postBalanceOutputAssetA);







    }


}
