pragma solidity ^0.4.11;


import './StandardToken.sol';
import '../libs/Ownable.sol';


/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  address[] public releaseAgents;

  function MintableToken() {
      addReleaseAgent(msg.sender);
  }

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier onlyReleaseAgents() {
      require(isReleaseAgent(msg.sender));
      _;
  }

  function isReleaseAgent(address _address) public constant returns (bool) {
      for(uint i; i < releaseAgents.length; ++i) {
          if ( _address == releaseAgents[i] ) {
              return true;
          }
      }
      return false;
  }

  function addReleaseAgent(address _releaseAgent) public onlyOwner {
      releaseAgents.push(_releaseAgent);
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyReleaseAgents canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyReleaseAgents public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}
