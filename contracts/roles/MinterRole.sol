pragma solidity ^0.5.0;

import "browser/Ownable.sol";
import "github.com/irobor/TelecomCoin/contracts/roles/Roles.sol";
import "github.com/irobor/TelecomCoin/contracts/ownership/Ownable.sol";

contract MinterRole is Ownable {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

  

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }
	/**
	* @dev checks the address CrowdSale
	* проверяет адрес CrowdSale
	*/
    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }
	/**
	* @dev adding address contract CrowdSale
	* добавляет адрес CrowdSale, только создатель контракта token
	*/
    function addMinter(address account) public onlyOwner {
        _addMinter(account);
    }
	/**
	* @dev invalidates the CrowdSale address,
    * Can only be called by the current owner.
	* аннулирует адрес CrowdSale , 
	* Может быть вызван только текущим владельцем.
	*/
    function renounceMinter(address account) public onlyOwner{
        _removeMinter(account);
    }
	/**
	* @dev See addMinter
	* */
    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }
	
	/**
	* @dev See renounceMinter
	* */
    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}
