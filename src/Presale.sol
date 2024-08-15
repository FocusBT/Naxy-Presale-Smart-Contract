// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Presale  {
    // AggregatorV3Interface internal dataFeedBNB;
    // AggregatorV3Interface internal dataFeedETH;

    mapping (address => uint) public totalTokensBought;
    mapping (address => uint) public referralIncome;
    
    IERC20 public NAXY;
    address public USDT_ADDRESS;
    address public BUSDC_ADDRESS;
    address public WETH_ADDRESS;

    address public owner;

    uint public currentPrice;
    uint public tokensSold;

    uint public amountInUSDT;
    uint public amountInETH;
    uint public amountInBNB;
    
    constructor() {
        // dataFeedBNB = AggregatorV3Interface(
        //     0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE  // BNB/USD
        // );
        // dataFeedETH = AggregatorV3Interface(
        //     0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e  // ETH/USD
        // );

        NAXY = IERC20(0xf96fF891F0c271a89Dae17346791B1FA524fC681);
        USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;
        WETH_ADDRESS = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8; 
        BUSDC_ADDRESS = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8; // change this 
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(owner != newOwner, "Invalid Address");
        owner = newOwner;
    }

    function sendAllSPY(address recipient) public onlyOwner {
        uint256 NaxyBalance = NAXY.balanceOf(address(this));
        require(NaxyBalance > 0, "No SPY tokens to send");
        NAXY.transfer(recipient, NaxyBalance);
    }

    // function getChainlinkDataFeedLatestAnswerBNB() public view returns (uint256) {
    //     (
    //         ,
    //         int answer,
    //         ,
    //         ,
    //     ) = dataFeedBNB.latestRoundData();
    //     return uint256(answer*1e10);
    // }

    // function getChainlinkDataFeedLatestAnswerETH() public view returns (uint256) {
    //     (
    //         ,
    //         int answer,
    //         ,
    //         ,
    //     ) = dataFeedETH.latestRoundData();
    //     return uint256(answer*1e10);
    // }

    function buyToken(uint currency, uint amountApproved) public returns (bool) {
        IERC20 tokenContract;
        uint totalUsdt;
        if(currency == 1){   // USDT
            tokenContract = IERC20(USDT_ADDRESS);
            amountInUSDT += amountApproved;
            totalUsdt = amountApproved;
        } else if(currency == 2) {
            tokenContract = IERC20(BUSDC_ADDRESS);
            amountInUSDT += amountApproved;
            totalUsdt = amountApproved;
        } else if(currency == 3) { // ETH
            tokenContract = IERC20(WETH_ADDRESS);
            amountInETH += amountApproved;
            // uint256 ethPriceInUSD = getChainlinkDataFeedLatestAnswerETH(); 
            totalUsdt = (amountApproved * 2635000000000000000000) / 1e18;   
        } else {
            return false;
        }

        uint256 tokensToBuy = totalUsdt / currentPrice;
        require(tokenContract.allowance(msg.sender, address(this)) >= amountApproved, "Insufficient allowance");
        require(tokenContract.balanceOf(msg.sender) >= amountApproved, "Insufficient balance");
        bool sent = tokenContract.transferFrom(msg.sender, owner, amountApproved);
        // totalRaised += amountApproved;
        require(sent, "Token transfer failed");
        tokensSold += tokensToBuy * 10 ** 18;   
        totalTokensBought[msg.sender] += tokensToBuy * 10 ** 18;
        return true;
    }

    function buyTokenWithBNB() public payable returns(bool) {
        require(msg.value > 0, "No BNB sent");
        // uint256 ethPriceInUSD = getChainlinkDataFeedLatestAnswerBNB(); 
        uint256 amountInUSD = (msg.value * 520000000000000000000) / 1e18;
        uint256 tokensToBuy = (amountInUSD * 1e18) / currentPrice;
        tokensSold += tokensToBuy; 
        totalTokensBought[msg.sender] += tokensToBuy * 10 ** 18;
        return true;
    }
}

