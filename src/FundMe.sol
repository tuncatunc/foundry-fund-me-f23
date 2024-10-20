// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();
error FundMe__NotEnoughEth(uint256 sent, uint256 required);
// gas: 707,396 non constant
// gas: 687,023 constant
// gas: 644,831 immutable

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;
    address[] public s_funders;
    mapping(address => uint256) public addressToAmountFunded;
    address private immutable i_owner;
    address private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = priceFeed;
    }

    function fund() public payable enoughEth(msg.value, MINIMUM_USD) {
        // Allow users to send $
        // Have a min $ sent
        // 1. How to send ETH to this contract?
        s_funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;

        // What's revert
        // Undo any actions that have been done, and send the remaining gas back
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;

        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // Reset funders array to a new address[] of length 0
        s_funders = new address[](0);

        // withdraw funds
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // Reset funders array to a new address[] of length 0
        s_funders = new address[](0);

        // withdraw funds
        // msg.sender = address
        // payable(msg.sender) = payable address
        payable(msg.sender).transfer(address(this).balance);
    }

    function getPriceFeedVersion() public view returns (uint256) {
        return PriceConverter.getPriceFeedVersion(s_priceFeed);
    }

    // modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    modifier enoughEth(uint256 _sent, uint256 _required) {
        uint256 sentUsd = msg.value.getConversionRate(s_priceFeed);
        if (sentUsd < _required) {
            revert FundMe__NotEnoughEth(_sent, _required);
        }
        _;
    }

    // what happens someone sends this contract ETH without calling fund function

    // receive()
    // fallback()

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getAddressToAmountFunded(address funder) public view returns (uint256) {
        return addressToAmountFunded[funder];
    }
}
