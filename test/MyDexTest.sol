// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/MyDex.sol";
import "../src/RNT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyDexTest is Test {
    MyDex public dex;
    RNT public rnt;
    IUniswapV2Router02 public router;
    address public constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public user;

    function setUp() public {
        rnt = new RNT();
        dex = new MyDex(UNISWAP_V2_ROUTER);

        user = address(this);

        // initial user's banance of RNT
        rnt.transfer(user, 1000 ether);

        // add liquidity to Uniswap V2 pool with 50 ETH and 500 RNT
        // timestamp + 6 seconds to avoid "Transaction reverted" error
        vm.prank(user);
        rnt.approve(UNISWAP_V2_ROUTER, 500 ether);
        IUniswapV2Router02(UNISWAP_V2_ROUTER).addLiquidityETH{value: 50 ether}(
            address(rnt),
            500 ether,
            0,
            0,
            user,
            block.timestamp
        );
    }


    function testExactETHForRNT() public {
        uint256 initialRntBalance = rnt.balanceOf(user);
        uint256 finalRntBalance = initialRntBalance;
        
        // user sells 10 ETH for RNT
        uint256 amountInETH = 10 ether;
        uint256 minRntOut = 80 ether; // assume minimum 80 ether RNT out, slipping protection

        address[] memory path = new address[](2);
        path[0] = WETH_ADDRESS;
        path[1] = address(rnt);

        vm.deal(user, amountInETH); // given user 10 ETH

        // execute sellETH by calling dex.sellETH
        vm.prank(user);
        dex.sellETH{value: amountInETH}(address(rnt), minRntOut);

        // update finalRntBalance
        finalRntBalance = rnt.balanceOf(user);
        assert(finalRntBalance > initialRntBalance);
        emit log_named_uint("RNT Received: ", finalRntBalance - initialRntBalance);
    }

    function testExactRNYForETH() public {
        uint256 initialEthBalance = address(user).balance;
        uint256 finalEthBalance = initialEthBalance;
        
        // user buys 100 RNT for ETH
        uint256 amountInRNT = 100 ether;
        uint256 minEthOut = 8 ether; // assume minimum 8 ether ETH out, slipping protection

        // address[] memory path = new address[](2);
        // path[0] = address(rnt);
        // path[1] = WETH_ADDRESS;


        // user approves dex to spend RNT
        vm.prank(user);
        rnt.approve(address(dex), amountInRNT);

        // execute buyETH by calling dex.buyETH
        vm.prank(user);
        dex.buyETH(address(rnt), amountInRNT, minEthOut);

        // update finalEthBalance
        finalEthBalance = address(user).balance;
        assert(finalEthBalance > initialEthBalance);
        emit log_named_uint("ETH Received: ", finalEthBalance - initialEthBalance);
    }

    // receive() is needed to receive ETH
    receive() external payable {}
    
    // fallback() is needed to receive ETH
    fallback() external payable {}
}