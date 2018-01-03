var Lottery = artifacts.require("./Lottery.sol");

contract('Lottery', (accounts) => {
    var contract;
    var account_one = accounts[0];
    var account_two = accounts[1];

    it('should deployed contract', async ()  => {
        assert.equal(undefined, contract);
        contract = await Lottery.deployed();
        assert.notEqual(undefined, contract);
    });

    it('get address contract', async ()  => {
        //console.log("contract address = " + contract.address);
        assert.notEqual(undefined, contract.address);
    });

});



