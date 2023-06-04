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
    function _burnFrom(address account, uint amount) external ;
}
contract LotteryContract is AccessControl{
    ITokenAddress tokenAddress;
    bool lotteryOpen;
    bytes32 BETTING_STARTER = bytes32(keccak256("BettingStarter"));
    uint closingTime;
    uint purachaseRatio;
    uint betPrice;
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

    modifier bettingOpen{
        require(lotteryOpen , "The Betting is not open");
        _;
    }
    /// @notice opens the lottery for recieving the bets 
    /// @param _closingTime the duration that you would like to open the bets for 
    function openBets(uint _closingTime) external canBet bettingClosed{
        require(_closingTime > block.timestamp, "The given time must be greater that the current time ");
        closingTime = _closingTime;
        lotteryOpen = true;
    }

    /// @notice grants the role of a better to a caller address
    /// @param to the address that is granted the role of the better 
    function grantBetterRole(address to) external isAdmin {
        _grantRole( BETTING_STARTER , to);
    }
    /// @notice returns the balance of the tokens of the calling account 
    function getBalance() public view returns(uint){
        return tokenAddress.balanceOf(msg.sender);
    }

    /// @notice transfers the tokens from the contract to the calling address based upon the purachase ratio
    function getTokens( ) external payable {
        require(msg.value > 0 , "You have to send some ether");
        tokenAddress.transfer(msg.sender , msg.value * purachaseRatio);
    }

    /// @notice returns the ether after converting the tokens to ether 
    /// @param amount The amount of tokens that you want to convert into ether
    function returnTokens(uint amount) external {
        tokenAddress._burnFrom(msg.sender , amount);
        (bool success , ) = payable(msg.sender).call{value : amount}("");
        require(success , "Transaction Failed");
    } 

    function bet() public bettingOpen{
        tokenAddress.transferFrom(msg.sender , address(this) , betPrice + betFee);
    }

    

}