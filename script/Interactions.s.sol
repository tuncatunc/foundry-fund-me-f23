// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

// Contract to fund FundMe contract
contract FundFundMe is Script {
    uint256 public constant SEND_AMOUNT = 1 ether;

    function fundFundMe(address fundMeAddress) public {
        vm.startBroadcast();
        FundMe(payable(fundMeAddress)).fund{value: SEND_AMOUNT}();
        vm.stopBroadcast();
        console.log("Funded FundMe contract at address: ", fundMeAddress);
    }

    function run() external {
        address mostRecentlyDeployedFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentlyDeployedFundMe);
    }
}

// Contract to withdraw funds from FundMe contract
contract WithdrawFundMe is Script {
    uint256 public constant SEND_AMOUNT = 1 ether;

    function withdrawFundMe(address fundMeAddress) public {
        vm.startBroadcast();
        FundMe(payable(fundMeAddress)).withdraw();
        vm.stopBroadcast();
        // console.log("Withdrew funds from FundMe contract at address: ", fundMeAddress);
    }

    function run() external {
        address mostRecentlyDeployedFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployedFundMe);
    }
}
