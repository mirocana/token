pragma solidity ^0.4.11;

import "./libs/Ownable.sol";

contract ApprovedCrowdsale is Ownable {

    address[] private approvedAddresses;

    function addApprovedAddress(address approvedAddress) onlyOwner external {
        approvedAddresses.push(approvedAddress);
    }

    function isAddressApproved(address approvedAddress) public constant returns (bool) {
        for(uint i = 0; i < approvedAddresses.length; ++i) {
            if ( approvedAddresses[i] == approvedAddress ) {
                return true;
            }
        }

        return false;
    }

    modifier onlyApproved() {
        require(isAddressApproved(msg.sender));
        _;
    }

}
