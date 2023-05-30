// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";
interface ITokenAddress{
    function transferFrom(address to , uint amount) external ;
    function transfer(address to , uint amount) external;

}
contract LotteryContract is AccessControl{
    ITokenAddress tokenAddress;
    bool lotteryOpen;
    bytes32 BETTING_STARTER = bytes32(keccak256("BettingStarter"));
    uint closingTime;
    uint purachaseRatio;
    uint betPrize;
    uint betFee;

    constructor(address _tokenAddress){
        tokenAddress = ITokenAddress(_tokenAddress);
        _grantRole(DEFAULT_ADMIN_ROLE , msg.sender);

    }

    modifier canBet{
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender ) || hasRole(BETTING_STARTER , msg.sender) , "The user doesn't have the required role");
        _;
    }

    modifier isAdmin{
        require(hasRole(DEFAULT_ADMIN_ROLE , msg.sender) , "The user is not the Admin");
        _;
    }

    modifier bettingClosed{
        require(!lotteryOpen , "The Betting is not Closed");
        _;
    }
    /// @notice opens the lottery for recieving the bets 
    function openBets(uint _closingTime) external canBet bettingClosed{
        require(_closingTime > block.timestamp, "The Betting time must be in the future ");
        closingTime = _closingTime; 
        lotteryOpen = true;
    }

    function grantBetterRole(address to) external isAdmin {
        _grantRole( BETTING_STARTER , to);
    }

    

}