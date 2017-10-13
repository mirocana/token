var MiroToken = artifacts.require("./MiroToken.sol");
var TokenStorage = artifacts.require("./TokenStorage.sol");
var MiroStartDistribution = artifacts.require("./MiroStartDistribution.sol");

contract('MiroStartDistribution', function(accounts) {

    before(async function() {

        this.token = await MiroToken.new();
        this.storage = await TokenStorage.new(this.token.address);

        this.distributionContract = await MiroStartDistribution.new(this.token.address, this.storage.address);

        this.token.addReleaseAgent(this.distributionContract.address);
        this.storage.addPromiseAgent(this.distributionContract.address);

        this.owner = accounts[0];
        this.distributor = accounts[1];
        this.distributionTokensAmount = 1000;
    });

    it('Contract should be in release agents', async function() {
        const isReleaseAgent = await this.token.isReleaseAgent(accounts[0]);

        assert.equal(isReleaseAgent, true, "Must be release agent");
    });

    it('Shouldn\'t call distrubute by not distrubutor', async function() {
        var result = false;

        try {
            result = await this.distributionContract.distribute({from : this.distributor});
        } catch ( error ) {
            assert.isAbove(error.message.indexOf('invalid opcode'), -1, 'Must be -1');
        }

        await assert.equal(result, false, 'Must be false');
    });

    it('Shouldn\'t add in distributors by NOT owner', async function() {
        try {
            await this.distributionContract.putDistributor(this.distributor, this.distributionTokensAmount, {from : this.distributor});
        } catch ( error ) {
            assert.isAbove(error.message.indexOf('invalid opcode'), -1, 'Must be -1');
        }
    });

    it('Should add in distributors by owner', async function() {
        try {
            await this.distributionContract.putDistributor(this.distributor, this.distributionTokensAmount);
        } catch ( error ) {
            assert.fail();
        }

        var isInDistributors = await this.distributionContract.isDistributor(this.distributor);

        assert.equal(isInDistributors, true, "Must be in distributors list");
    });


    it('Should distribution complete on approved distributor', async function() {
        try {
            await this.distributionContract.distribute({from : this.distributor});
        } catch ( error ) {
            assert.fail();
        }

        const paymentPromise = await this.storage.getPaymentPromise(this.distributor);
        assert.equal(paymentPromise.valueOf(), this.distributionTokensAmount);
    });

    it('Should distribute from TokenStorage by owner', async function() {
        try {
            await this.storage.payout(this.distributor, this.distributor, this.distributionTokensAmount, {from : this.owner});
        } catch( error ) {
            console.log(error);
            assert.fail();
        }

        const balance = await this.token.balanceOf(this.distributor);
        assert.equal(balance.valueOf(), this.distributionTokensAmount);
    });

});
