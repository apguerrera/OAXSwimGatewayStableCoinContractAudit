pragma solidity ^0.4.23;   // AG: changed to 0.4.23

import "AddressStatus.sol";

interface MembershipInterface {
    function isMember(address guy) public returns (bool);
}

contract MockOAXMembership is AddressStatus, MembershipInterface {
    constructor(DSAuthority authority) AddressStatus(authority) public {
    }

    function isMember(address guy) public returns (bool) {
        return status[guy];   // AG: changed from function() to index[]
    }
}
