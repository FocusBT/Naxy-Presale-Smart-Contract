// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Naxy} from "../src/Naxy.sol";
import {USDT} from "../src/USDT.sol";
import {BUSDC} from "../src/BUSDC.sol";
import {Ether} from "../src/WETH.sol";
import {console2} from "forge-std/console2.sol";
import {Presale} from "../src/Presale.sol";


contract TestBeeBox is Test {
    Presale public presale;
    Naxy public naxy;
    USDT public usdt;
    BUSDC public busdc;
    Ether public weth;
    
    address public owner;
    
    

    address addr1 = vm.addr(1);
    address addr2 = vm.addr(2);
    address addr3 = vm.addr(3);
    address addr4 = vm.addr(4);
    address addr5 = vm.addr(5);
    address addr6 = vm.addr(6);
    address addr7 = vm.addr(7);
    address addr8 = vm.addr(8);
    address addr9 = vm.addr(9);
    address addr10 = vm.addr(10);
    address addr11 = vm.addr(11);

    address public tokenAddr;
    address public contractAddr;


    function setUp() public {
        usdt = new USDT();
        busdc = new BUSDC();
        naxy = new Naxy();
        weth = new Ether();

        presale = new Presale(address(usdt), address(busdc), address(weth), address(naxy));
        
        contractAddr = address(presale);
        owner = msg.sender;

        

    }

    function test_token() public {
        usdt.mint(addr1, 2000 * 10 ** 18);
        usdt.mint(addr2, 2000 * 10 ** 18);
        usdt.mint(addr3, 2000 * 10 ** 18);
        usdt.mint(addr4, 2000 * 10 ** 18);
        usdt.mint(addr5, 2000 * 10 ** 18);

        busdc.mint(addr1, 2000 * 10 ** 18);
        busdc.mint(addr2, 2000 * 10 ** 18);
        busdc.mint(addr3, 2000 * 10 ** 18);
        busdc.mint(addr4, 2000 * 10 ** 18);
        busdc.mint(addr5, 2000 * 10 ** 18);
        
        naxy.mint(address(presale), 200000000000 * 10 ** 18);
        // naxy.mint(addr2, 2000 * 10 ** 18);
        // naxy.mint(addr3, 2000 * 10 ** 18);

        weth.mint(addr1, 100 * 10 ** 18);
        weth.mint(addr2, 100 * 10 ** 18);
        weth.mint(addr3, 100 * 10 ** 18);
        weth.mint(addr4, 100 * 10 ** 18);
        weth.mint(addr5, 100 * 10 ** 18);
        
        vm.deal(addr1, 1000 ether);
        vm.prank(addr1);
        presale.buyTokenWithBNB{value: 1}(addr2);
        

        presale.toggleLock();
        vm.prank(addr1);
        presale.claim();
        console2.log("naxy balance: ",naxy.balanceOf(addr1));
        console2.log("total sold: ", presale.tokensSold());

        vm.prank(addr2);
        presale.claim();
        
        console2.log("naxy balance of address 2: ",naxy.balanceOf(addr2));
        
        // vm.deal(addr3, 1000 ether);
        // vm.prank(addr3);
        // presale.buyTokenWithBNB{value: 1 ether}(addr1);
        // console2.log("tokensSold", presale.tokensSold()/10**18);
        // vm.deal(addr4, 1000 ether);
        // vm.prank(addr4);
        // presale.buyTokenWithBNB{value: 1 ether}(addr4);
        // console2.log("tokensSold", presale.tokensSold()/10**18);

        // vm.prank(addr1);
        // usdt.approve(contractAddr, 520 * 10 ** 18);
        
        // vm.prank(addr1);
        // presale.buyToken(1, 520 * 10 ** 18, addr2);

        // presale.toggleLock();

        // vm.prank(addr1);
        // presale.claim();

        // console2.log("naxy balance: ",naxy.balanceOf(addr1));
        // console2.log("total sold: ", presale.tokensSold());

        // vm.prank(addr2);
        // presale.claim();
        
        // console2.log("naxy balance of address 2: ",naxy.balanceOf(addr2));


        // vm.prank(addr1);
        // usdt.approve(contractAddr, 10 * 10 ** 18);
        
        // vm.prank(addr1);
        // presale.buyToken(1, 10 * 10 ** 18, addr2);

        // vm.prank(addr2);
        // presale.claim();


        // console2.log("owner usdt balance",usdt.balanceOf(presale.owner()));

        // console2.log(presale.owner());


        // vm.prank(addr3);
        // weth.approve(contractAddr, 1 * 10 ** 18);

        // vm.prank(addr3);
        // presale.buyToken(3, 1 * 10 ** 18, addr1);

        // console2.log("tokensSold", presale.tokensSold()/10**18);

        // vm.prank(addr1);
        // presale.claim();
        // console2.log(naxy.balanceOf(addr1) / 10**18);


        // vm.prank(addr4);
        // weth.approve(contractAddr, 1 * 10 ** 18);

        // vm.prank(addr4);
        // presale.buyToken(3, 1 * 10 ** 18, addr3);

        // console2.log("tokensSold", presale.tokensSold()/10**18);

        // vm.prank(addr5);
        // weth.approve(contractAddr, 1 * 10 ** 18);

        // vm.prank(addr5);
        // presale.buyToken(3, 1 * 10 ** 18, addr4);

        

        

        // console2.log(presale.users(msg.sender));
        


    }


   
}