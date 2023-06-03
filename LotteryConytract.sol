
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";
interface ITokenAddress{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory );
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

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

    /// @notice grants the role of a better to a caller address
    /// params to the address that is granted the role of the better 
    function grantBetterRole(address to) external isAdmin {
        _grantRole( BETTING_STARTER , to);
    }

    

}