// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    DeployFundMe deployFundMe;
    address private constant USER = address(0x123);
    uint256 private constant FUND_AMOUNT = 10 ether;

    function setUp() external {
        deployFundMe = new DeployFundMe();

        // FundMeTest contract is deployer and owner of FundMe contract
        fundMe = deployFundMe.run();
    }

    function testMinimumAmountToDepositIsFiveUsd() public view {
        uint256 minimumUsd = 5e18;
        assertEq(fundMe.MINIMUM_USD(), minimumUsd);
    }

    function testOwnerIsSetToDeployer() public view {
        // FundMeTest contract is deployer and owner of FundMe contract
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        assertEq(fundMe.getPriceFeedVersion(), 4);
    }

    function testFundRevertsWithoutEnoughEth() public {
        vm.expectRevert(abi.encodeWithSelector(FundMe.FundMe__NotEnoughEth.selector, 0.001 ether, 5e18));
        // FundMeTest contract is deployer and owner of FundMe contract
        fundMe.fund{value: 0.001 ether}();
    }

    function testFundSuccess() public {
        console.log("owner", fundMe.getOwner());
        console.log("msg.sender", msg.sender);
        console.log("address(this).balance", address(this).balance);

        fundMe.fund{value: 10 ether}();
        console.log("address(this).balance", address(this).balance);

        // assertEq(address(fundMe).balance, 10 ether);
        console.log("funders", fundMe.s_funders(0));
        assertEq(fundMe.s_funders(0), address(this));
    }

    function testFundUpdatesFunders() public funded {
        vm.prank(USER);
        fundMe.fund{value: 10 ether}();

        assertEq(fundMe.getAddressToAmountFunded(USER), 10 ether);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        fundMe.fund{value: 10 ether}();

        assertEq(fundMe.getAddressToAmountFunded(USER), 10 ether);

        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Action
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        console.log("startingOwnerBalance", startingOwnerBalance);
        console.log("endingOwnerBalance", endingOwnerBalance);
        console.log("startingFundMeBalance", startingFundMeBalance);
        console.log("endingFundMeBalance", endingFundMeBalance);

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 noFunders = 10;
        uint160 startFunderIndex = 2;

        for (uint160 i = startFunderIndex; i < noFunders; i++) {
            hoax(address(i), FUND_AMOUNT);
            fundMe.fund{value: FUND_AMOUNT}();
        }

        uint256 startingOwnerBalance = address(fundMe.getOwner()).balance; // Contract Owner Balance
        uint256 startingFundMeBalance = address(fundMe).balance; // Contract Balance

        // Action
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    modifier funded() {
        vm.deal(USER, FUND_AMOUNT);
        _;
    }
}
