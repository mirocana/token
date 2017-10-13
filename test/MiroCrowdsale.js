var MiroCrowdsale = artifacts.require("./MiroCrowdsale.sol");
var TokenStorage = artifacts.require("./TokenStorage.sol");
var MiroToken = artifacts.require("./MiroToken.sol");

contract('MiroCrowdsale', function(accounts) {

    this.multisigStartBalance = 0;

    before(async function() {
        this.owner = accounts[0];
        this.multisig = accounts[1];
        this.restricted = accounts[2];

        this.rate = 1000;
        this.hardcap = 1 * 10 ** 8;
        this.restrictedPercent = 40;

        this.startAt = Math.round(Date.now()/1000)-5*24*60*60;
        this.period = 21;

        this.token = await MiroToken.new();
        this.storage = await TokenStorage.new(this.token.address);
        this.sale = await MiroCrowdsale.new(this.token.address, this.storage.address, this.multisig, this.restricted, this.startAt, this.period, this.rate, this.hardcap, this.restrictedPercent);

        this.token.addReleaseAgent(this.sale.address);
        this.storage.addPromiseAgent(this.sale.address);

        this.investor = accounts[3];
        this.investmentAmount = 1;//1 ether

        this.restrictedAmount = Math.floor(this.investmentAmount * this.rate * this.restrictedPercent / (100 - this.restrictedPercent));
        console.log(this.restrictedAmount);
        this.finishedTotalSupply = this.restrictedAmount + this.investmentAmount * this.rate;
    });

    it('Should multisig address equals this.multisig', async function() {
        var multisig = await this.sale.multisig.call();

        assert.equal(multisig, this.multisig, "Multisig address is wrong");
    });

    it('Should restricted account equals this.restricted', async function() {
        var restricted = await this.sale.restricted.call();

        assert.equal(restricted, this.restricted, "Restricted address is wrong");
    });

    it('Should contains right startAt', async function() {
        var startAt = await this.sale.startAt.call();

        assert.equal(startAt, this.startAt, "Start date is wrong");
    });

    it('Should contains right endAt', async function() {
        var endAt = await this.sale.endAt.call();
        var calculatedEndAt = this.startAt + this.period*24*60*60;

        assert.equal(endAt, calculatedEndAt, "End date is wrong");
    });

    it('Should be active', async function() {
        var startAt = await this.sale.startAt.call();
        var endAt = await this.sale.endAt.call();

        var now = Math.round(Date.now()/1000);

        assert.equal( (now > startAt ) && (now <= endAt), true, "Sale not active" );
    });

    it('Should NOT send tokens to unapproved purchaser', async function() {
        this.multisigStartBalance = web3.eth.getBalance(this.investor);

        try {
            await this.sale.sendTransaction({
                value: this.investmentAmount * 10 ** 18,
                from: this.investor
            });
        } catch( error ) {
            assert.isAbove(error.message.search('invalid opcode'), -1, 'Invalid opcode error must be returned');
        }

        const balance = await this.token.balanceOf(this.investor);
        assert.equal(balance.valueOf(), 0, "Not null tokens balance" );
    });

    it('Should UNapproved investor balance change less then investing amount (only gas)', async function() {
        var currentBalance = web3.eth.getBalance(this.investor);

        var difference = this.multisigStartBalance.sub(currentBalance);

        assert.equal(difference < 1 * 10 ** 18, true);
    });

    it('Shouldn\'t add address to approved not by owner', async function() {
        try {
            await this.sale.addApprovedAddress(this.investor, {from : accounts[4]});
        } catch (error) {
            assert.isAbove(error.message.search('invalid opcode'), -1, 'Invalid opcode error must be returned');
        }

        const isApproved = await this.sale.isAddressApproved.call(this.investor);
        assert.equal(isApproved, false);
    });

    it('Should add address to approved', async function() {
        await this.sale.addApprovedAddress(this.investor);

        const isApproved = await this.sale.isAddressApproved.call(this.investor);

        assert.equal(isApproved, true);
    });

    it('Should create payment promise for purchaser in TokenStorage', async function() {
        this.multisigStartBalance = await web3.eth.getBalance(this.multisig);

        await this.sale.sendTransaction({
            value: this.investmentAmount * 10 ** 18,
            from: this.investor
        });

        const balance = await this.storage.getPaymentPromise(this.investor);

        assert.equal(balance.valueOf(), this.investmentAmount * this.rate );
    });

    it('Should distribute from TokenStorage by owner', async function() {
        try {
            await this.storage.payout(this.investor, this.investor, this.investmentAmount * this.rate, {from : this.owner});
        } catch( error ) {
            assert.fail();
        }

        const balance = await this.token.balanceOf(this.investor);
        assert.equal(balance.valueOf(), this.investmentAmount * this.rate);
    });

    it('Should be change multisig balance in ether', async function() {
        const balance = await web3.eth.getBalance(this.multisig);

        assert.equal(balance.valueOf(), this.multisigStartBalance.add(this.investmentAmount * 10 ** 18).valueOf());
    });

    it('Try to call mint and some tokens. Should be 0 tokens.', async function() {
        var result = await this.token.mint.call(accounts[5], 5199);

        const balance = await this.token.balanceOf(accounts[5]);

        assert.equal(balance.valueOf(), 0 );
    });

    it('Try call finish', async function() {
        await this.sale.finish();
        var finished = await this.sale.finished();

        assert.equal(finished, true);
    });

    it('Should exist real number of tokens on restricted address', async function() {
        const balance = await this.token.balanceOf(this.restricted);

        assert.equal(balance.valueOf(), this.restrictedAmount);
    });

    it('Should be total supply alright', async function() {

        const totalSupply = await this.token.totalSupply.call();

        assert.equal(totalSupply, this.finishedTotalSupply)
    });
});
