pragma solidity ^0.4.11;

import "./libs/Ownable.sol";
import "./MiroToken.sol";
import "./math/SafeMath.sol";

contract TokenStorage is Ownable {

    using SafeMath for uint;

    mapping (address => uint256) public paymentPromises;
    address[] public promiseAgents;

    MiroToken public token;

    modifier onlyPromiseAgent() {
        require(isPromiseAgent(msg.sender));
        _;
    }

    function TokenStorage(address _tokenAddress) {
        token = MiroToken(_tokenAddress);
    }

    function addPromiseAgent(address _promiseAgent) public onlyOwner {
        promiseAgents.push(_promiseAgent);
    }

    function isPromiseAgent(address _address) public constant returns (bool) {
        for(uint i; i < promiseAgents.length; ++i) {
            if ( _address == promiseAgents[i] ) {
                return true;
            }
        }
        return false;
    }

    function addPaymentPromise(address _address, uint256 _amount) onlyPromiseAgent external {
        if ( paymentPromises[_address] != uint256(0x0) ) {
            paymentPromises[_address].add(_amount);
        } else {
            paymentPromises[_address] = _amount;
        }
    }

    function getPaymentPromise(address _address) external constant returns(uint256) {
        return paymentPromises[_address];
    }

    function payout(address _from, address _to, uint256 _amount) onlyOwner external {
        require( paymentPromises[_from] != uint256(0x0) );
        require( _amount >= paymentPromises[_from] );

        paymentPromises[_from] = paymentPromises[_from].sub(_amount);
        token.transfer(_to, _amount);
    }
}
