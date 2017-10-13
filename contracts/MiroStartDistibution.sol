pragma solidity ^0.4.11;

import "./libs/Ownable.sol";
import "./TokenStorage.sol";
import "./MiroToken.sol";

contract MiroStartDistribution is Ownable {

    MiroToken public token;
    TokenStorage public tokenStorage;

    mapping (address => uint256) public distributors;

    bool public finishDistributing;

    modifier notFinished() {
        require(finishDistributing != true);
        _;
    }

    function MiroStartDistribution(address _token, address _tokenStorage) {
        token = MiroToken(_token);
        tokenStorage = TokenStorage(_tokenStorage);

        finishDistributing = false;
    }

    function putDistributor(address _address, uint256 _amount) onlyOwner {
        distributors[_address] = _amount;
    }

    function isDistributor(address _address) public constant returns (bool) {
        if( distributors[_address] != uint256(0x0) ) {
            return true;
        }
        return false;
    }

    function distribute() notFinished external {
        require(isDistributor(msg.sender));

        uint256 amount = distributors[msg.sender];

        token.mint(tokenStorage, amount);
        tokenStorage.addPaymentPromise(msg.sender, amount);
    }

    function finish() {
        finishDistributing = true;
    }

}
