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

    uint256 FACTOR = 10**18;

    function setUp() public {
        bridge = new UniswapBridge(ROLLUP_PROCESSOR, ROUTER, FACTORY);
        eth = Types.AztecAsset(1, WETH, Types.AztecAssetType.ETH);
        dai = Types.AztecAsset(2, DAI, Types.AztecAssetType.ERC20); 
        usdc = Types.AztecAsset(3, USDC, Types.AztecAssetType.ERC20);
        inputAssetB = Types.AztecAsset(4, address(0x2), Types.AztecAssetType.ERC20);
        outputAssetB = Types.AztecAsset(5, address(0x3), Types.AztecAssetType.ERC20);

    }

    receive() external payable {}
    fallback() external payable {}

    function test_convert_ethForTokens() public {
        (bool sent, ) = address(bridge).call{value: 1 ether}("");
        require(sent, "Failed to send Ether");
        uint256 inputValue = 1 ether;
        Types.AztecAsset memory inputAssetA = eth;
        Types.AztecAsset memory outputAssetA = dai;
        uint256 bridge_preBalanceInputAssetA = address(bridge).balance;
        uint256 processor_preBalanceOutputAssetA = IERC20(outputAssetA.erc20Address).balanceOf(ROLLUP_PROCESSOR);
        emit log_named_uint("Pre-swap balance of the bridge contract", bridge_preBalanceInputAssetA/FACTOR);
        //emit log_named_uint("Pre-swap balance of the rollup processor", processor_preBalanceOutputAssetA/FACTOR);
        (uint outputValueA,,) = bridge.convert(
            inputAssetA,
            inputAssetB,
            outputAssetA,
            outputAssetB,
            inputValue,
            0,
            0
            );
        uint256 bridge_postBalanceInputAssetA = address(bridge).balance;
        uint256 processor_postBalanceOutputAssetA = IERC20(outputAssetA.erc20Address).balanceOf(ROLLUP_PROCESSOR);
        //emit log_named_uint("Post-swap balance of the bridge contract", bridge_postBalanceInputAssetA/FACTOR);
        emit log_named_uint("Post-swap balance of the rollup processor", processor_postBalanceOutputAssetA/FACTOR);
        assertEq(bridge_preBalanceInputAssetA - inputValue, bridge_postBalanceInputAssetA);
        assertEq(processor_preBalanceOutputAssetA + outputValueA, processor_postBalanceOutputAssetA);
    }


    function test_convert_tokensForEth() public {
        uint256 inputValue = 10000*FACTOR;
        Types.AztecAsset memory inputAssetA = dai;
        Types.AztecAsset memory outputAssetA = eth;
        IERC20(inputAssetA.erc20Address).transfer(address(bridge), inputValue);
        uint256 bridge_preBalanceInputAssetA = IERC20(inputAssetA.erc20Address).balanceOf(address(bridge));
        uint256 processor_preBalanceOutputAssetA = address(ROLLUP_PROCESSOR).balance;
        emit log_named_uint("Pre-swap balance of the bridge contract", bridge_preBalanceInputAssetA/FACTOR);
        //emit log_named_uint("Pre-swap balance of the rollup processor", processor_preBalanceOutputAssetA/FACTOR);
        (uint outputValueA,,) = bridge.convert(
            inputAssetA,
            inputAssetB,
            outputAssetA,
            outputAssetB,
            inputValue,
            0,
            0
            );
        uint256 bridge_postBalanceInputAssetA = IERC20(inputAssetA.erc20Address).balanceOf(address(bridge));
        uint256 processor_postBalanceOutputAssetA = address(ROLLUP_PROCESSOR).balance;
        //emit log_named_uint("Post-swap balance of the bridge contract", bridge_postBalanceInputAssetA/FACTOR);
        emit log_named_uint("Post-swap balance of the bridge contract", processor_postBalanceOutputAssetA/FACTOR);
        assertEq(bridge_preBalanceInputAssetA - inputValue, bridge_postBalanceInputAssetA);
        assertEq(processor_preBalanceOutputAssetA + outputValueA, processor_postBalanceOutputAssetA);
    }

    function test_convert_tokensForTokens() public {
        uint256 inputValue = 10000*FACTOR;
        Types.AztecAsset memory inputAssetA = dai;
        Types.AztecAsset memory outputAssetA = usdc;
        IERC20(inputAssetA.erc20Address).transfer(address(bridge), inputValue);
        uint256 bridge_preBalanceInputAssetA = IERC20(inputAssetA.erc20Address).balanceOf(address(bridge));
        uint256 processor_preBalanceOutputAssetA = IERC20(outputAssetA.erc20Address).balanceOf(address(ROLLUP_PROCESSOR));
        emit log_named_uint("Pre-swap balance of the bridge contract", bridge_preBalanceInputAssetA/FACTOR);
        //emit log_named_uint("Pre-swap balance of the rollup processor", processor_preBalanceOutputAssetA/FACTOR);
        (uint outputValueA,,) = bridge.convert(
            inputAssetA,
            inputAssetB,
            outputAssetA,
            outputAssetB,
            inputValue,
            0,
            0
            );
        uint256 bridge_postBalanceInputAssetA = IERC20(inputAssetA.erc20Address).balanceOf(address(bridge));
        uint256 processor_postBalanceOutputAssetA = IERC20(outputAssetA.erc20Address).balanceOf(address(ROLLUP_PROCESSOR));
        //emit log_named_uint("Post-swap balance of the bridge contract", bridge_postBalanceInputAssetA/FACTOR);
        emit log_named_uint("Post-swap balance of the rollup processor", processor_postBalanceOutputAssetA/10**6); // 6 is the number of USDC's decimals.
        //assertEq(bridge_preBalanceInputAssetA - inputValue, bridge_postBalanceInputAssetA);
        //assertEq(processor_preBalanceOutputAssetA + outputValueA, processor_postBalanceOutputAssetA);
    }






}
