// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IXReceiver} from "@connext/interfaces/core/IXReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

/**
 * @title DestinationGreeter
 * @notice Example destination contract that stores a greeting.
 */
contract DestinationGreeter is IXReceiver {
  string public greeting;
  address public owner;
  address public tokenOut;
  uint256 public amountOut;
  // The token to be paid on this domain
  IERC20 public token;
    ISwapRouter swapRouter;
  constructor(address _token, ISwapRouter _swapRouter) {
    swapRouter = ISwapRouter(_swapRouter);
    token = IERC20(_token);
    owner = msg.sender;
  }

   modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

  /** @notice The receiver function as required by the IXReceiver interface.
    * @dev The Connext bridge contract will call this function.
    */
  function xReceive(
    bytes32 _transferId,
    uint256 _amount,
    address _asset,
    address _originSender,
    uint32 _origin,
    bytes memory _callData
  ) external returns (bytes memory) {
    // Check for the right token
    require(
      _asset == address(token),
      "Wrong asset received"
    );
    // Enforce a cost to update the greeting
    require(
      _amount > 0,
      "Must pay at least 1 wei"
    );

    // Unpack the _callData
    (address _tokenOut) = abi.decode(_callData, (address));
    tokenOut=_tokenOut;
    uint24 poolFee = 3000;
    uint256 _amountOut = swap(_asset,_tokenOut,poolFee);
    amountOut = _amountOut;
  }
  function swap(
        address tokenIn,
        address tokenOut,
        uint24 fee
        
    ) public payable returns (uint256 amountOut) {
        uint24 poolFee = fee;
        IERC20 asset_fromToken;
        uint256 amountToTrade;
        asset_fromToken = IERC20(tokenIn);
        amountToTrade = asset_fromToken.balanceOf(address(this));

        asset_fromToken.approve(address(swapRouter), amountToTrade);

      

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp + 30000,
                amountIn: amountToTrade,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }
  function updateToken(address _token) external onlyOwner {
    token = IERC20(_token);
  }
}