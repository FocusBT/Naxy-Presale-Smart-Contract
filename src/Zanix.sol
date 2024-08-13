// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
contract Zanix {
    AggregatorV3Interface internal dataFeedBNB;
    AggregatorV3Interface internal dataFeedETH;
    
    IERC20 public ZANIX;

    constructor() {
        dataFeedBNB = AggregatorV3Interface(
            0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE  // BNB/USD
        );
        dataFeedETH = AggregatorV3Interface(
            0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e  // ETH/USD
        );
        ZANIX = IERC20(0xf96fF891F0c271a89Dae17346791B1FA524fC681);
        USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;
        BUSDT_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;      
        owner = msg.sender;
    }
    
    uint256 public startingPrice = 2000000000000000; 
    uint256 public endingPrice = 4000000000000000; 
    uint256 public tokensSold;
    address public USDT_ADDRESS;
    address public BUSDT_ADDRESS;
    uint256 public totalRaised;
    address public owner;

    uint public amountInUSDT;
    uint public amountInBUSDT;
    uint public amountInETH;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(owner != newOwner, "Invalid Address");
        owner = newOwner;
    }

    function sendAllBnb(address payable recipient) public onlyOwner {
        require(address(this).balance > 0, "No BNB to send");
        recipient.transfer(address(this).balance);
    }

    function getChainlinkDataFeedLatestAnswerBNB() public view returns (uint256) {
        (
            ,
            int answer,
            ,
            ,
        ) = dataFeedBNB.latestRoundData();
        return uint256(answer*1e10);
    }

    function getChainlinkDataFeedLatestAnswerETH() public view returns (uint256) {
        (
            ,
            int answer,
            ,
            ,
        ) = dataFeedETH.latestRoundData();
        return uint256(answer*1e10);
    }

    function calculatePrice() public view returns (uint256) {
        if (tokensSold >= (35000000 * 10 ** 18)) {
            return endingPrice;
        }
        uint A = endingPrice - startingPrice;
        uint B = A * tokensSold;
        uint C = startingPrice * (35000000 * 10 ** 18) + B;
        uint currentPrice = C / (35000000 * 10 ** 18);
        return currentPrice;
    }

    function withrawZanix(address recipient, uint256 amount) public onlyOwner {
        ZANIX.transfer(recipient, amount);
    }
    

    function buyToken(uint currency, uint amountApproved) public returns(bool) {
       IERC20 tokenContract;
       if(currency == 1){   // USDT
           tokenContract = IERC20(USDT_ADDRESS);
           amountInUSDT += amountApproved
       } else if(currency == 2) { // ETH
           tokenContract = IERC20(BUSDT_ADDRESS);
           amountInBUSDT += amountApproved
       } else {
           return false;
       }
       uint256 currentPrice = calculatePrice();
       uint256 tokensToBuy = amountApproved / currentPrice; // Calculate the number of tokens to buy based on the current price
       require(tokenContract.allowance(msg.sender, address(this)) >= amountApproved, "Insufficient allowance");
       require(tokenContract.balanceOf(msg.sender) >= amountApproved, "Insufficient balance");
       require(tokensToBuy <= ((35000000 * 10 ** 18) - tokensSold), "Not enough tokens left");
       bool sent = tokenContract.transferFrom(msg.sender, owner, amountApproved);
       totalRaised += amountApproved;
       require(sent, "Token transfer failed");
       tokensSold += tokensToBuy * 10 ** 18;   
       ZANIX.transfer(msg.sender, tokensToBuy * 10 ** 18);
       return true;
    }

    function buyTokenWithETH() public payable returns(bool) {
        require(msg.value > 0, "No ETH sent");

        uint256 ethPriceInUSD = getChainlinkDataFeedLatestAnswer(); 
        uint256 amountInUSD = (msg.value * ethPriceInUSD) / 1e18;
        totalRaised += amountInUSD ;
        uint256 currentPrice = calculatePrice(); 
        uint256 tokensToBuy = (amountInUSD * 1e18) / currentPrice;

        require(tokensToBuy <= ((35000000 * 10 ** 18) - tokensSold), "Not enough tokens left");

        tokensSold += tokensToBuy; 
        ZANIX.transfer(msg.sender, tokensToBuy);
        return true;
    }


}