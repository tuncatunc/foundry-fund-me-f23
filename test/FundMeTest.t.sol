// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    function setUp() external {
        // FundMeTest contract is deployer and owner of FundMe contract
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumAmountToDepositIsFiveUsd() public view {
        uint256 minimumUsd = 5e18;
        assertEq(fundMe.MINIMUM_USD(), minimumUsd);
    }

    function testOwnerIsSetToDeployer() public view {
        // FundMeTest contract is deployer and owner of FundMe contract
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        assertEq(fundMe.getPriceFeedVersion(), 4);
    }
}
