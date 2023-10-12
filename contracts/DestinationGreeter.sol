// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
pragma abicoder v2;

import {ForwarderXReceiver} from "./ForwarderXReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";


/**
 * @title DestinationGreeter
 * @notice Example destination contract that stores a greeting.
 */
contract DestinationGreeter is ForwarderXReceiver {
  string public greeting;

  // The token to be paid on this domain


  ISwapRouter swapRouter;

    // take an address of provider
    constructor(
        address _connext,
        ISwapRouter _swapRouter
    ) ForwarderXReceiver(_connext){
      swapRouter = ISwapRouter(_swapRouter);
    }

  
  function swapExactInputSingle(address token0, address token1, uint256 amountIn) external returns (uint256 amountOut) {

        IERC20 tokenA = IERC20(token0);
        uint256 amountToTrade;
        amountToTrade= tokenA.balanceOf(address(this));
        tokenA.approve(address(swapRouter), amountToTrade);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: token0,
                tokenOut: token1,
                fee: 3000,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountToTrade,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }

  
   function _prepare(
    bytes32 _transferId,
    bytes memory _data,
    uint256 _amount,
    address _asset
  ) internal override returns (bytes memory){
    
    (address payable tokenIn, address payable tokenOut, address sender) = abi.decode(_data, (address , address , address));
    uint256 amountOut = this.swapExactInputSingle(tokenIn, tokenOut, _amount);
    return abi.encode(amountOut,tokenOut,sender);
  }

  function _forwardFunctionCall(
  bytes memory _preparedData,
  bytes32 _transferId,
  uint256 _amount,
  address _asset
) internal override virtual returns (bool){

  (uint256 amountOut, address tokenOut, address sender) = abi.decode(_preparedData, (uint256,address,address));
  IERC20 tokenB = IERC20(tokenOut);
  tokenB.transfer(sender,amountOut);
  return true;
}

}

