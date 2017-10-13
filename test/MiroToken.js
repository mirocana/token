var MiroToken = artifacts.require("./MiroToken.sol");

contract('MiroToken', function(accounts) {

    before(async function() {
        this.token = await MiroToken.new();
    })

    it('Should name equals Mirocana Token', async function() {
        assert(this.token.name.call(), "Mirocana Token", "Token name is wrong");
    });

    it('Should symbol equals MIRO', async function() {
        assert(this.token.symbol.call(), "MIRO", "Token symbol is wrong");
    });

    it('Should decimals is 18', async function() {
        assert(this.token.decimals.call(), 18, "Token decimals is wrong");
    });

    it('Should not mint from not owner', async function() {
        const startBalance = await this.token.balanceOf(accounts[1]);

        try {
            await this.token.mint(accounts[1], 10000, {from : accounts[2]});
        } catch ( error ) {
            assert.isAbove(error.message.search('invalid opcode'), -1, 'Invalid opcode must be returned');
        }

        const endBalance = await this.token.balanceOf(accounts[1]);

        assert.equal(startBalance.valueOf(), endBalance.valueOf(), 'Must be equals');
    })

});
