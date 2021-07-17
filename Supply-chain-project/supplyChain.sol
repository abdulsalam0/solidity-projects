pragma solidity ^0.6.0;

contract Item{
    uint public princeInWei;
    uint public pricePaid;
    uint public index;
    
    ItemManager parentContract;
    
    constructor(ItemManager _parentContract, uint _priceInWei, uint _index) public {
        princeInWei = _priceInWei;
        parentContract = _parentContract;
        index = _index;
    }
    
    
    // low level function call
    receive() external payable {
        require(pricePaid == 0, "Item is paid already");
        require(princeInWei == msg.value, "Only full payments allowed");
        pricePaid += msg.value;
        // (bool success,)=address(parentContract).call.value(msg.value)(abi.encodeWithSignature("triggerPayment(uint256)", index));
        (bool success,)=address(parentContract).call{value:msg.value}(abi.encodeWithSignature("triggerPayment(uint256)", index));
        require(success, "This transaction wasn't successful, canceling");
    }
    
    fallback() external {
        
    }
}

contract ItemManager {
    
    enum SupplyChainState{Created, Paid, Delivered}
    
    struct ItemObj{
        Item _item;
        string _identifier;
        uint _itemPrice;
        ItemManager.SupplyChainState _state;
    }
    
    mapping(uint => ItemObj) public items;
    
    uint _itemIndex;
    
    event SupplyChainStep(uint _itemIndex, uint _step, address _itemAddress);
    
    function createItem (string memory _id, uint _itemPrice) public {
        
        Item item = new Item(this,_itemPrice,_itemIndex);
        items[_itemIndex]._item = item;
        items[_itemIndex]._identifier = _id;
        items[_itemIndex]._itemPrice = _itemPrice;
        items[_itemIndex]._state = SupplyChainState.Created;
        
        emit SupplyChainStep(_itemIndex , uint(items[_itemIndex]._state), address(item));
        _itemIndex++;
        
    }
    
    function triggerPayment(uint _id) payable public {
        require(items[_id]._itemPrice == msg.value, "Make sure the paid amount is correct");
        require(items[_id]._state == SupplyChainState.Created, "This item is further in the chain");
        items[_id]._state = SupplyChainState.Paid;
        
        emit SupplyChainStep(_id , uint(items[_id]._state), address(items[_id]._item));
    }
    
    function triggerDelivery(uint _id) public {
        require(items[_id]._state == SupplyChainState.Paid, "This item is has not been paid for yet");
        items[_id]._state = SupplyChainState.Delivered;
        
        emit SupplyChainStep(_id , uint(items[_id]._state), address(items[_id]._item));
    }
}