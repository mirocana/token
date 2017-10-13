pragma solidity ^0.4.11;

import "./MiroToken.sol";
import "./TokenStorage.sol";
import "./ApprovedCrowdsale.sol";

contract MiroPresale is ApprovedCrowdsale {

    using SafeMath for uint;

    address public multisig;

    uint256 public startAt;
    uint256 public endAt;

    MiroToken public token;
    TokenStorage public tokenStorage;


    uint public rate;

    modifier whenActive() {
        require(now > startAt && now < endAt);
        _;
    }

    function MiroPresale(address _token,  address _tokenStorage, address _multisig, uint256 _startAt, uint _period, uint _rate) {
        token = MiroToken(_token);
        multisig = _multisig;

        startAt = _startAt;
        endAt = _startAt + _period * 1 days;

        rate = _rate;

        tokenStorage = TokenStorage(_tokenStorage);
    }

    function calculateBonus(uint amount) private returns (uint) {
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

    function createTokens() whenActive payable {
        multisig.transfer(msg.value);

        uint amount = rate.mul(msg.value).div(1 ether);
        uint totalAmount = amount.add(calculateBonus(amount));

        token.mint(address(tokenStorage), totalAmount);
        tokenStorage.addPaymentPromise(msg.sender, totalAmount);
    }

    function() external onlyApproved payable {
        createTokens();
    }

}
