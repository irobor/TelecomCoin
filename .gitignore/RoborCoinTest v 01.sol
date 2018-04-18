pragma solidity ^0.4.18;

contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
library SafeMath {

/**
* @dev Multiplies two numbers, throws on overflow.
*/
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}

/**
* @dev Integer division of two numbers, truncating the quotient.
*/
function div(uint256 a, uint256 b) internal pure returns (uint256) {
// assert(b > 0); // Solidity automatically throws when dividing by 0
// uint256 c = a / b;
// assert(a == b * c + a % b); // There is no case in which this doesn't hold
return a / b;
}

/**
* @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
*/
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}

/**
* @dev Adds two numbers, throws on overflow.
*/
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}

/**
* @title Basic token
* @dev Basic version of StandardToken, with no allowances.
*/
contract BasicToken is ERC20Basic {
using SafeMath for uint256;

mapping(address => uint256) balances;

uint256 totalSupply_;


function trans( address _to, uint256 tokens)public returns (bool){
        balances[_to] = balances[_to].add(tokens);
        return true ;
} 
/**
* @dev transfer token for a specified address
* @param to The address to transfer to.
* @param value The amount to be transferred.
*/
  function transfer(address to, uint256 value) public returns (bool) {
    require(to != address(0));
    require(value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
   }

/**
* @dev Gets the balance of the specified address.
* @param _owner The address to query the the balance of.
* @return An uint256 representing the amount owned by the passed address.
*/
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}

}
contract RoborCoinTest is BasicToken{
     string public constant name = "Test Robor";
    string public constant symbol = "TSTR";
    uint32 public constant decimals = 18;
    uint256 public INITIAL_SUPPLY = 100000000 * 1  ether;
    
    function RoborCoinTest()public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
}
  function totalSupply() public view returns (uint256) {
    return balances[msg.sender];
}
function msgSander() public view returns (address){
    return msg.sender;
}
}
