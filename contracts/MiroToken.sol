pragma solidity ^0.4.11;

import "./libs/MintableToken.sol";

contract MiroToken is MintableToken {

    string public symbol = "MIRO";
    string public name = "Mirocana Token";
    uint public decimals = 18;
}
