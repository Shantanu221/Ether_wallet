// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;


import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    
    uint256 public constant minimumUsd = 10 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;
    uint256 public balance;

    constructor(){
        owner = msg.sender;
    }

    function fund() public payable  {
    require(getConversionRate(msg.value) > minimumUsd ,"Not enough !");
    funders.push(msg.sender);
    addressToAmountFunded[msg.sender] += msg.value;
    balance+=msg.value;
    }

    function getPrice() public view returns(uint256){
        //Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 price,,,) = priceFeed.latestRoundData();
        //ETH in USD
        return uint256(price * 1e18);
    }

    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function withdraw() public onlyOwner {

        for(uint256 funderIndex=0;funderIndex<funders.length;funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        
        funders = new address[] (0);

        (bool sent,) = payable(msg.sender).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
        balance=0;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not owner!");
        _;
    }

    receive() external payable { fund();}

    fallback() external payable { fund();}

}