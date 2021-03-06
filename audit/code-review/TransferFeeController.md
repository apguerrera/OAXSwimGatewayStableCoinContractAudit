# TransferFeeController

Source file [../../chain/contracts/TransferFeeController.sol](../../chain/contracts/TransferFeeController.sol).

<br />

<hr />

```javascript
pragma solidity 0.4.23;

import "TransferFeeControllerInterface.sol";
import "dappsys.sol";

contract TransferFeeController is TransferFeeControllerInterface, DSMath, DSAuth {
    //transfer fee is calculated by transferFeeAbs+amt*transferFeeBps
    uint public defaultTransferFeeAbs;

    uint public defaultTransferFeeBps;

    constructor(DSAuthority _authority, uint defaultTransferFeeAbs_, uint defaultTransferFeeBps_)
    public {
        setAuthority(_authority);
        setOwner(0x0);
        defaultTransferFeeAbs = defaultTransferFeeAbs_;
        defaultTransferFeeBps = defaultTransferFeeBps_;
    }

    function divRoundUp(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, 1), y / 2) / y;
    }

    function calculateTransferFee(address /*from*/, address /*to*/, uint wad)
    public
    view
    returns (uint) {
        return defaultTransferFeeAbs + divRoundUp(mul(wad, defaultTransferFeeBps), 10000);
    }

    function setDefaultTransferFee(uint defaultTransferFeeAbs_, uint defaultTransferFeeBps_)
    public
    auth
    {
        defaultTransferFeeAbs = defaultTransferFeeAbs_;
        defaultTransferFeeBps = defaultTransferFeeBps_;
    }
}

```
