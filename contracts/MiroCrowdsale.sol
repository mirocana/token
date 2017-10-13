pragma solidity ^0.4.11;

import "./MiroToken.sol";
import "./TokenStorage.sol";
import "./ApprovedCrowdsale.sol";

contract MiroCrowdsale is ApprovedCrowdsale {

    using SafeMath for uint;

    address public multisig;
    address public restricted;

    uint256 public startAt;
    uint256 public endAt;

    uint public restrictedPercent;

    MiroToken public token;
    TokenStorage public tokenStorage;

    uint public rate;

    uint public hardcap;

    bool public finished;

    modifier whenActive() {
        require(now > startAt && now < endAt);
        _;
    }

    modifier notFinished() {
        require(finished == false);
        _;
    }

    modifier underHardcap() {
        require(token.totalSupply() < hardcap );
        _;
    }

    function MiroCrowdsale(address _token, address _tokenStorage, address _multisig, address _restricted, uint256 _startAt, uint _period, uint _rate, uint _hardcap, uint _restrictedPercent) {

        token = MiroToken(_token);
        tokenStorage = TokenStorage(_tokenStorage);

        finished = false;

        multisig = _multisig;
        restricted = _restricted;

        startAt = _startAt;
        endAt = _startAt + _period * 1 days;

        rate = _rate;
        hardcap = _hardcap;
        restrictedPercent = _restrictedPercent;
    }

    function calculateBonus(uint amount) private returns(uint) {
        uint bonusAmount = 0;

        if ( amount > 10000 ) {
            bonusAmount = amount.mul(5).div(100);
        } else if ( amount > 100000 ) {
            bonusAmount = amount.mul(10).div(100);
        } else if ( amount > 1000000 ) {
            bonusAmount = amount.mul(20).div(100);
        }

        return bonusAmount;
    }

    function createTokens() underHardcap whenActive private returns (uint) {
        multisig.transfer(msg.value);

        uint amount = rate.mul(msg.value).div(1 ether);
        uint totalAmount = amount.add(calculateBonus(amount));

        token.mint(tokenStorage, totalAmount);
        tokenStorage.addPaymentPromise(msg.sender, totalAmount);
    }

    function finish() onlyOwner notFinished external {
        uint totalSupply = token.totalSupply();
        uint restrictedTokens = totalSupply.mul(restrictedPercent).div(100 - restrictedPercent);

        token.mint(restricted, restrictedTokens);

        token.finishMinting();

        finished = true;
    }

    function() payable onlyApproved external {
        createTokens();
    }

}
