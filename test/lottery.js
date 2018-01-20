var Lottery = artifacts.require("./Lottery.sol");

contract('Lottery', (accounts) => {
    var contract;
    var account_owner = accounts[0];
    var account_one = accounts[1];
    var account_two = accounts[2];
    var account_three = accounts[3];
    var sendWei = 210;

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

    it('test twist', async ()  => {
        await contract.newRaund({from:account_owner});

        await contract.buyTicket({from:account_one, value:sendWei});
        var player_one = await contract.getPlayer.call(0);
        assert.equal(0,player_one[3]);
        await contract.buyTicket({from:account_two, value:sendWei});
        var player_two = await contract.getPlayer.call(1);
        assert.equal(0,player_two[3]);
        await contract.buyTicket({from:account_three, value:sendWei});
        var player_three = await contract.getPlayer.call(2);
        assert.equal(0,player_three[3]);

        var winner = await contract.twist.call({from:account_owner});

        player_one = await contract.getPlayer.call(0);
        //assert.notEqual(0,player_one[3]);

        player_two = await contract.getPlayer.call(1);
        player_three = await contract.getPlayer.call(2);

        console.log("winner = " + winner[1] + " : " + winner[2] + " : " + winner[3]);
    });


});



