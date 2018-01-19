var Lottery = artifacts.require("./Lottery.sol");

contract('Lottery', (accounts) => {
    var contract;
    var account_owner = accounts[0];
    var account_one = accounts[1];
    var account_two = accounts[2];
    var sendWei = 10;

    it('should deployed contract', async ()  => {
        assert.equal(undefined, contract);
        contract = await Lottery.deployed();
        assert.notEqual(undefined, contract);
    });

    it('get address contract', async ()  => {
        assert.notEqual(undefined, contract.address);
    });

    it('set/get Player', async ()  => {
        await contract.buyTicket({from:account_one, value:sendWei});
        var player = await contract.getPlayer.call(0);
        assert.equal(account_one, player[0]);
        assert.equal(sendWei, player[1]);
    });

    it('get random number', async ()  => {
        await contract.buyTicket({from:account_two, value:sendWei});
        var player = await contract.getPlayer.call(1);
        assert.equal(0,player[3]);
        await contract.twist({from:account_owner});
        player = await contract.getPlayer.call(1);
        assert.notEqual(0,player[3]);
        var randomNumber = await contract.getRandomNumber.call(0);
        assert.notEqual(randomNumber, player[3]);
    });

});



