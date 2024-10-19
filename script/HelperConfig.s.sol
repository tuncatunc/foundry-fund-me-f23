// SPDX-License-Identifier: MIT

// 1. Deploy mocks on local anvil
// 2. Keep track of the address of the deployed mocks

pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockAggregatorV3Interface.sol";

contract HelperConfig is Script {
    // If we're on local anvil chain, we deploy mocks
    // Otherwise, we use the real contracts from live chain

    NetworkConfig public activeConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeConfig = getSepoliahEthConfig();
        } else {
            activeConfig = getAnvilEthConfig();
        }
    }

    function getSepoliahEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return config;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        MockV3Aggregator priceFeed = new MockV3Aggregator(8, 200000000000);
        NetworkConfig memory config = NetworkConfig({priceFeed: address(priceFeed)});
        return config;
    }
}
