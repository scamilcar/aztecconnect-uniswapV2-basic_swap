// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./UniswapBridge.sol";

contract UniswapBridgeTest is DSTest {
    UniswapBridge bridge;

    function setUp() public {
        bridge = new UniswapBridge();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
