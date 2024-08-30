// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;
import {console2} from "forge-std/console2.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Presale  {
    // AggregatorV3Interface internal dataFeedBNB;
    // AggregatorV3Interface internal dataFeedETH;

    struct ReferralDetails {
        uint amountReward;
        uint totalBought;
        uint currency;
        address addr;
        uint timeStamp;
    }

    struct User {
        address reffBy;
        uint totalTokensBought;
        uint referralIncome;
        ReferralDetails[] referralDetails;
    }
    mapping(address => User) public users;

    
    IERC20 public NAXY;
    address public USDT_ADDRESS;
    address public BUSDC_ADDRESS;
    address public WETH_ADDRESS;

    address public owner;

    uint public currentPrice = 100000000000000;
    uint public tokensSold;
    uint public amountInUSDT;
    bool public isLocked = true;
    
    constructor(address usdt, address usdc, address weth, address naxy) {
        // dataFeedBNB = AggregatorV3Interface(
        //     0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE  // BNB/USD
        // );
        // dataFeedETH = AggregatorV3Interface(
        //     0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e  // ETH/USD
        // );

        // NAXY = IERC20(0xf96fF891F0c271a89Dae17346791B1FA524fC681);
        // USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;
        // WETH_ADDRESS = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8; 
        // BUSDC_ADDRESS = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8; // change this 


        NAXY = IERC20(naxy);
        USDT_ADDRESS = usdt;
        WETH_ADDRESS = weth; 
        BUSDC_ADDRESS = usdc; // change this 


        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function changePrice(uint newPrice) public onlyOwner {
        currentPrice = newPrice;
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

    function activateNaxyAddress(address naxy) public onlyOwner() {
        NAXY = IERC20(naxy);
        // NAXY_ADDRESS = naxy;
    }

    function toggleLock() public onlyOwner() {
        isLocked = !isLocked;
    }

    function change(uint amount) public onlyOwner() {
        amountInUSDT = amount;
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

    function referralAwardToLevels(uint amount, uint currency) internal {
        address curr = users[msg.sender].reffBy;
        for(uint i = 1; i <= 3; i++){
            if(curr == address(0) || curr == owner) break;
            uint reward = (amount * getRewardPercentage(uint8(i))) / 100;
            users[curr].referralDetails.push(ReferralDetails({
                addr: msg.sender,
                currency: currency,
                totalBought: amount,
                amountReward: reward,
                timeStamp: block.timestamp 
            }));
            users[curr].referralIncome += reward;
            curr = users[curr].reffBy;
        }
    }

    function getRewardPercentage(uint8 level) internal pure returns (uint) {
        if (level == 1) return 10;
        if (level == 2) return 5;
        if (level == 3) return 3;
        return 0; // Default to 0% for unsupported levels
    }


    function buyToken(uint currency, uint amountApproved, address reffBy) public returns (bool) {
        IERC20 tokenContract;
        uint totalUsdt;
        if(currency == 1){   // USDT
            tokenContract = IERC20(USDT_ADDRESS);
            totalUsdt = amountApproved;
        } else if(currency == 2) { // BUSDC
            tokenContract = IERC20(BUSDC_ADDRESS);
            totalUsdt = amountApproved;
        } else if(currency == 3) { // ETH
            tokenContract = IERC20(WETH_ADDRESS);
            // uint256 ethPriceInUSD = getChainlinkDataFeedLatestAnswerETH(); 
            uint256 ethPriceInUSD = 2635000000000000000000; 
            totalUsdt = (amountApproved * ethPriceInUSD) / 10**18;
        } else {
            return false;
        }
        require(totalUsdt >= 10 * 10 ** 18, "Min amount to buy is worth $ 10");
        
        amountInUSDT += totalUsdt;
        console2.log("totalUsdt: ", totalUsdt);
        require((reffBy != msg.sender || reffBy != address(0)), "Invalid Referral.");
        if(users[msg.sender].reffBy == address(0)){
            users[msg.sender].reffBy = reffBy;
        } 
   
        uint256 tokensToBuy = totalUsdt / currentPrice;
        console2.log("tokensToBuy: ", tokensToBuy);
        require(tokenContract.allowance(msg.sender, address(this)) >= amountApproved, "Insufficient allowance");
        require(tokenContract.balanceOf(msg.sender) >= amountApproved, "Insufficient balance");
        
        bool sent = tokenContract.transferFrom(msg.sender, owner, amountApproved);
        require(sent, "Token transfer failed");
        
        tokensSold += tokensToBuy * 10 ** 18;  
        console2.log("tokensSold: ", tokensSold);
        
        users[msg.sender].totalTokensBought += tokensToBuy * 10 ** 18;
        referralAwardToLevels(tokensToBuy * 10 ** 18, currency);
        return true;
    }

    function buyTokenWithBNB(address reffBy) public payable returns(bool) {
        require(msg.value > 0, "No BNB sent");
        require((reffBy != msg.sender || reffBy != address(0)), "Invalid Referral.");
        if(users[msg.sender].reffBy == address(0)){
            users[msg.sender].reffBy = reffBy;
        }
        // uint256 ethPriceInUSD = getChainlinkDataFeedLatestAnswerBNB(); 
        uint256 ethPriceInUSD = 520000000000000000000; 
        uint256 totalUsdt = (msg.value * ethPriceInUSD) / 1e18;
        console2.log("totalUsdt", totalUsdt);
        require(totalUsdt * 10 ** 18 >= 10 * 10 ** 18, "Min amount to buy is worth $ 10");
        uint256 tokensToBuy = (totalUsdt * 1e18) / currentPrice;
        console2.log("tokensToBuy", tokensToBuy);
        tokensSold += tokensToBuy * 10 ** 18; 
        console2.log("tokensSold", tokensSold);
        amountInUSDT += totalUsdt * 10 ** 18;
        users[msg.sender].totalTokensBought += tokensToBuy * 10 ** 18;
        referralAwardToLevels(tokensToBuy * 10 ** 18, 4);
        // payable(owner).transfer(msg.value);
        return true;
    }

    function claim() public {
        require(!isLocked, "claim function is locked");
        uint totalAmount = users[msg.sender].totalTokensBought + users[msg.sender].referralIncome;
        console2.log("totalAmount: ", totalAmount);
        uint256 NaxyBalance = NAXY.balanceOf(address(this));
        require(NaxyBalance >= totalAmount && totalAmount > 0, "No SPY tokens to send");
        NAXY.transfer(msg.sender, totalAmount);
        users[msg.sender].totalTokensBought = 0;
        users[msg.sender].referralIncome = 0;
    }

    function getReferralDetails(address user) public view returns (ReferralDetails[] memory) {
        return users[user].referralDetails;
    }

    
}
