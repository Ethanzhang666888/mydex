// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// Import last version of Uniswap V2 Router
import "v2-periphery/interfaces/IUniswapV2Router02.sol"; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract MyDex {
    IUniswapV2Router02 public uniswapRouter;

    constructor(address _uniswapRouter) {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
    }


    /**
     * @dev Sell ETH for tokens
     * @param buyToken The token to buy
     * @param minBuyAmount The minimum amount of tokens to buy
     */

    function sellETH(address buyToken, uint256 minBuyAmount) external payable  {
        require(buyToken != address(0), "Invalid token address");
        require(msg.value > 0, "ETH amount must be greater than 0");

        // Create path
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = buyToken;

        // Swap ETH for tokens
        uniswapRouter.swapExactETHForTokens{value: msg.value}(
            minBuyAmount,
            path,
            msg.sender,
            block.timestamp
        );
    }

    /**
     * @dev Buy ETH for tokens
     * @param sellToken The token to sell
     * @param sellAmount The amount of tokens to sell
     * @param minBuyAmount The minimum amount of ETH to buy
     */
     
    function buyETH(address sellToken, uint256 sellAmount, uint256 minBuyAmount) external  {
        require(sellToken != address(0), "Invalid token address");
        require(sellAmount > 0, "Token amount must be greater than 0");
        
        // Transfer tokens from sender to contract
        IERC20(sellToken).transferFrom(msg.sender, address(this), sellAmount);
        IERC20(sellToken).approve(address(uniswapRouter), sellAmount);

        // Create path
        address[] memory path = new address[](2);
        path[0] = sellToken;
        path[1] = uniswapRouter.WETH();

        // Swap tokens for ETH
        uniswapRouter.swapExactTokensForETH(
            sellAmount,
            minBuyAmount,
            path,
            msg.sender,
            block.timestamp
        );
    }
}
