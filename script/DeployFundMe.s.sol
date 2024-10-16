// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    FundMe public fundMe;

    function setUp() public {}

    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        (address priceFeed) = helperConfig.activeConfig();
        //
        vm.startBroadcast();
        // Mock Price Feed Contract

        fundMe = new FundMe(priceFeed);

        vm.stopBroadcast();
        return fundMe;
    }
}
