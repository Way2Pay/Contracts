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
  mapping(string=>string) public txStatus;

  //events
  event TransferCompleted(string indexed txId, address from, address _token, uint256 amount, bytes32 transferId);
  event SwapFailed(bytes32 transferId,string txId);

  // The token to be paid on this domain
  address public token;
    ISwapRouter swapRouter;
  constructor(address _token, ISwapRouter _swapRouter) {
    swapRouter = ISwapRouter(_swapRouter);
    token = _token;
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
    // Enforce a cost to update the greeting
    require(
      _amount > 0,
      "Must pay at least 1 wei"
    );

    // Unpack the _callData
    (string memory txId) = abi.decode(_callData, (string));
    uint24 poolFee = 3000;
    if(_asset != address(token))
    {uint256 _amountOut = swap(_asset,address(token),poolFee,txId,_transferId);
    emit TransferCompleted(txId, _originSender,_asset, _amountOut,_transferId);
    }
    emit TransferCompleted(txId, _originSender, _asset, _amount,_transferId);
    txStatus[txId]="Completed";
  }
  function swap(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        string memory txId,
        bytes32 transferId
        
    ) public payable returns (uint256 amountOut) {
        uint24 poolFee = fee;
        IERC20 asset_fromToken;
        uint256 amountToTrade;
        asset_fromToken = IERC20(tokenIn);
        amountToTrade = asset_fromToken.balanceOf(address(this));
        amountOut=amountToTrade;
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

        try swapRouter.exactInputSingle(params) returns(uint256 _amountOut){
          amountOut=_amountOut;
          return amountOut;
        }catch{
          emit SwapFailed(transferId,txId);
        }
    }
    function withdrawToken(address _token, uint256 _amount)external onlyOwner{
      IERC20 asset = IERC20(_token);
      require(asset.balanceOf(address(this))>_amount);
      asset.transferFrom(address(this),owner, _amount);

    }

  function updateToken(address _token) external onlyOwner {
    token = _token;
  }
}