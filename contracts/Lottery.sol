pragma solidity ^0.4.18;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}


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
    using SafeMath for uint256;
    enum State {Active, Twist, Closed}
    State public state;
    uint256 public weiRaised;
    uint8 blockDelay;
    struct Player {
        uint256 weiAmount;
        uint256 numberBlock;
        uint8 number;
        address wallet;
    }
    Player[] players;
    uint8[] setLoto;

    mapping(address => uint256) public deposited;

    event Closed();
    event ErrorMessage(address indexed sender, string textError);

    function Lottery() public
    {
        state = State.Active;
        weiRaised = 0;
        owner = msg.sender;
        blockDelay = 0;
    }

    // fallback function can be used to buy tokens
    function() payable public {
        buyTicket();
    }

    // low level token purchase function
    function buyTicket() public payable {
        require(state == State.Active);
        uint256 weiAmount = msg.value;
        require(msg.sender != address(0));
        weiRaised = weiRaised.add(weiAmount);
        deposited[msg.sender] = deposited[msg.sender].add(weiAmount);
        players.push(Player({
            weiAmount: weiAmount,
            numberBlock: block.number,
            number: 0,
            wallet: msg.sender
        }));
        setLoto.push(0);
        // update state
    }

    function twist() public onlyOwner {
        state = State.Twist;
        uint8 randomNumber = 0;
        uint length = players.length;
        for (uint i = 0; i < length; i++) {
            randomNumber = getRandomNumber(i);
            players[i].number = randomNumber;
            setLoto[i] = randomNumber;
        }
    }

    function isIdentic(uint8 number) private view returns (bool){
        for (uint j = 0; j < setLoto.length; j++){
            if(setLoto[j] == number){
                return true;
            }
        }
        return false;
    }

    function definePlayerWinner(uint8 goal) public onlyOwner returns (uint winner){
        require(state == State.Twist);
        uint8 difference = 255;
        uint8 currDifference = 0;
        winner = 0;
        for(uint i = 0; i < players.length; i++){
            if(players[i].number >= goal){
                currDifference = players[i].number - goal;
            } else {
                currDifference = goal - players[i].number;
            }
            if(difference > currDifference){
                difference = currDifference;
                winner = i;
            }
        }

        state = State.Closed;
    }

    function getPlayer(uint _number) public view returns(address, uint256, uint256){
        require(_number >= 0);
        if(players.length < _number){revert();}
        return (players[_number].wallet, players[_number].weiAmount, players[_number].numberBlock);
    }

    function getRandomNumber(uint _number) public returns(uint8 wheelResult)
    {
        // block.blockhash - hash of the given block - only works for 256 most recent blocks excluding current
        require(_number >=0 && players.length > 0);
        address walletPlayer = players[_number].wallet;
        uint256 playerBlock = players[_number].numberBlock;

        bytes32 blockHash = block.blockhash(playerBlock+blockDelay);

        if (blockHash == 0)
        {
            ErrorMessage(msg.sender, "Cannot generate random number");
            wheelResult = 200;
        }
        else
        {
            bytes32 shaPlayer = keccak256(walletPlayer, blockHash);

            wheelResult = uint8(uint256(shaPlayer)%399);
        }
    }

    function remove() public onlyOwner {
        state = State.Closed;
        selfdestruct(owner);
    }

}

