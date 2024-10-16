// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    /**
     * Returns the latest price of ETH/USD.
     */
    function getPrice(address priceFeedAddr) internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddr);
        // 0x694AA1769357215DE4FAC081bf1f309aDC325306 // Sepolia Testnet
        //0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF // ZkSync Sepolia Testnet

        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,
        ) = priceFeed.latestRoundData();
        return uint256(price) * 1e10; // Price has 8 decimals, so multiply by 1e10
    }

    function getConversionRate(uint256 ethAmount, address priceFeedAddr) internal view returns (uint256) {
        // 1ETH?
        // 3500 * 1e18
        uint256 ethPrice = getPrice(priceFeedAddr);
        // (3500 * 1e18 * 1 * 1e18) / 1e18
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;

        return ethAmountInUsd;
    }

    function getPriceFeedVersion(address priceFeedAddr) internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddr);
        // 0x694AA1769357215DE4FAC081bf1f309aDC325306 // Sepolia Testnet
        // 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF // ZkSync Sepolia Testnet

        return priceFeed.version();
    }
}
