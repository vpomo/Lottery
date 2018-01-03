pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    event OwnerChanged(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function changeOwner(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnerChanged(owner, newOwner);
        owner = newOwner;
    }

}


contract Lottery is Ownable {

    enum State {Active, Refunding, Closed}
    State public state;


    event Closed();

    function Lottery() public
    {
        state = State.Active;
    }

    // fallback function can be used to buy tokens
    function() payable public {
        buyParticipation(msg.sender);
    }

    // low level token purchase function
    function buyParticipation(address investor) public payable {
        uint256 weiAmount = msg.value;
        require(investor != address(0));
        // update state
    }

    function remove() public onlyOwner {
        selfdestruct(owner);
    }

}

