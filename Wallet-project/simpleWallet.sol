pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./SafeMath.sol";

contract SimpleWallet is Ownable {
    
    using SafeMath for uint;
    
    event allowanceUpdateEvent(address indexed _fromWho, address indexed _toWho, uint _oldAmount, uint _newAmount);
    event withdrawEvent(address indexed _fromWho, address indexed _toWho, uint _amount, uint _oldAmount, uint _newAmount);
    event moneyReciviedEvent(address indexed _formWho ,uint _amount);
    
    struct Allowance {
        bool paused;
        uint amount;
    }
    
    mapping(address => Allowance) allowances;

    
    
    
    //------------Withdraw------------//
    
    function withdrawAllToOwner() public onlyOwner{
        
        emit withdrawEvent( owner(), owner(), (address(this).balance), (address(this).balance), 0);
        payable(owner()).transfer(address(this).balance);
    }
    
    function withdrawMoney(address payable _to, uint _amount) public {
        if(msg.sender == owner()){
            require(address(this).balance >= _amount, "funds are too low");
            uint reducedAmount = address(this).balance.sub(_amount);
            emit withdrawEvent( msg.sender, _to, _amount, address(this).balance, reducedAmount);
            _to.transfer(_amount);
        }else {
            require(address(this).balance >= _amount, "funds are too low");
            require(allowances[msg.sender].amount >= _amount, "Funds not found allows too low");
            require( allowances[msg.sender].paused == false, "Your allowance is paused");
            
            emit withdrawEvent( msg.sender, _to, _amount, allowances[msg.sender].amount, (allowances[msg.sender].amount).sub(_amount));
            (allowances[msg.sender].amount).sub( _amount);
            
            _to.transfer(_amount);
        }
    }
    
    
    //------------ allowance------------//
    
    // create an allowance (only owner)
    
    function createAllowance(address _address, uint _allowanceAmount) public onlyOwner {
        emit allowanceUpdateEvent(msg.sender, _address, allowances[_address].amount, _allowanceAmount);
        allowances[_address].amount = _allowanceAmount;
    }
    
    // update an allowance (only owner)
    
    function updateAllowance(address _address, uint _allowanceAmount) public onlyOwner {
        emit allowanceUpdateEvent(msg.sender, _address, allowances[_address].amount, _allowanceAmount);
         allowances[_address].amount = _allowanceAmount;
    }
    
    // remove an allowance (only owner)
    
    function removeAllowance(address _address) public onlyOwner {
         allowances[_address].amount = 0;
    }
    
    // pause an allowance (only owner)
    
    function setPauseAllowance(address _address, bool _pause) public onlyOwner {
         allowances[_address].paused = _pause ;
    }
    
    
    
    //------------deposit------------//
    receive() external payable{
        emit moneyReciviedEvent(msg.sender ,msg.value);
        
    }
    
    function renounceOwnership()public onlyOwner view override {
        revert("Can't run this function");
    }
    
    fallback() external payable {
        emit moneyReciviedEvent(msg.sender ,msg.value);
    }
}