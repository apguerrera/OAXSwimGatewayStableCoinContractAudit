# OAX Swim Gateway Stable Coin Contract Audit

## Summary

Status: Work in progress

Commits from [swim-gateway/stable-coin master-gitlab branch](https://github.com/swim-gateway/stable-coin/tree/master-gitlab) in commits [75cc80c](https://github.com/swim-gateway/stable-coin/commit/75cc80c5d494625d3e7262756973ec0394dfcf11) and [a53dce5](https://github.com/swim-gateway/stable-coin/commit/a53dce5fb53f2ff4461d15c2e3450faf0a9b61ac). Additionally, the pull request #1 [https://github.com/swim-gateway/stable-coin/pull/1/commits/daa965ad77e41629d6389879e120e68eb34c3593](https://github.com/swim-gateway/stable-coin/pull/1/commits/daa965ad77e41629d6389879e120e68eb34c3593) was merged into this branch.

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Recommendations](#recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Testing](#testing)
* [Code Review](#code-review)

<br />

<hr />

## Recommendations

* [] **HIGH IMPORTANCE**
* [] **MEDIUM IMPORTANCE**
* [] **LOW IMPORTANCE**

<br />

<hr />

## Potential Vulnerabilities

No potential vulnerabilities have been identified in the crowdsale, token and vesting contracts.

<br />

<hr />

## Scope

This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds
contributed to these contracts are not easily attacked or stolen by third parties. The secondary aim of this audit is to
ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to
highlight any areas of weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the OneLedger's business proposition, the individuals
involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence

As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition
before funding any crowdsales.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on
the crowdsale beneficiary's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as
duplicating crowdsale websites. Potential participants should NOT just click on any links received through these messages.
Scammers have also hacked the crowdsale website to replace the crowdsale contract address with their scam address.

Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address
matches the audited source code, and that the deployment parameters are correctly set, including the constant parameters.

<br />

<hr />

## Risks

Ethers contributed to the crowdsale contract are transferred directly to the crowdsale wallet, and tokens are generated for the contributing account. This reduces the severity of any attacks on the crowdsale contract.

The token contract is a simple extension of the OpenZeppelin library token contract that is used by many other tokens.

Once the vesting contract is deployed, and tokens transferred to the vesting contract, only the beneficiary or the vesting contract owner is able to execute the token release function when the tokens are vested.

<br />

<hr />

## Testing

Details of the testing environment can be found in [test](test).

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy crowdsale contract
  * [x] Deploy token contract

<br />

<hr />

## Code Review

* [ ] [code-review/AddressStatus.md](code-review/AddressStatus.md)
  * [ ] contract AddressStatus is DSAuth
* [ ] [code-review/FiatToken.md](code-review/FiatToken.md)
  * [ ] contract FiatToken is DSToken, ERC20Auth, TokenAuth
* [ ] [code-review/Gate.md](code-review/Gate.md)
  * [ ] contract Gate is DSSoloVault, ERC20Events, DSMath, DSStop
* [ ] [code-review/GateRoles.md](code-review/GateRoles.md)
  * [ ] contract GateRoles is DSRoles
* [ ] [code-review/GateWithFee.md](code-review/GateWithFee.md)
  * [ ] contract GateWithFee is Gate
* [ ] [code-review/Kyc.md](code-review/Kyc.md)
  * [ ] contract AddressControlStatus is DSAuth
  * [ ] contract KycAmlStatus is DSAuth
  * [ ] contract ControllableKycAmlRule is ERC20Authority, TokenAuthority
  * [ ] contract NoKycAmlRule is ControllableKycAmlRule
  * [ ] contract BoundaryKycAmlRule is NoKycAmlRule
  * [ ] contract FullKycAmlRule is BoundaryKycAmlRule
  * [ ] contract MembershipAuthorityInterface
  * [ ] contract MembershipWithNoKycAmlRule is DSAuth, NoKycAmlRule
  * [ ] contract MembershipWithBoundaryKycAmlRule is DSAuth, BoundaryKycAmlRule
  * [ ] contract MembershipWithFullKycAmlRule is DSAuth, FullKycAmlRule
* [ ] [code-review/LimitController.md](code-review/LimitController.md)
  * [ ] contract LimitController is DSMath, DSStop
* [ ] [code-review/LimitSetting.md](code-review/LimitSetting.md)
  * [ ] contract LimitSetting is DSAuth, DSStop
* [ ] [code-review/Membership.md](code-review/Membership.md)
  * [ ] interface MembershipInterface
  * [ ] contract MockOAXMembership is AddressStatus, MembershipInterface
* [ ] [code-review/TokenAuth.md](code-review/TokenAuth.md)
  * [ ] interface ERC20Authority
  * [ ] contract ERC20Auth is DSAuth
  * [ ] interface TokenAuthority
  * [ ] contract TokenAuth is DSAuth
* [ ] [code-review/TokenRules.md](code-review/TokenRules.md)
  * [ ] contract BaseRules is ERC20Authority, TokenAuthority
  * [ ] contract BoundaryKycRules is BaseRules
  * [ ] contract FullKycRules is BoundaryKycRules
* [ ] [code-review/TransferFeeController.md](code-review/TransferFeeController.md)
  * [ ] contract TransferFeeController is TransferFeeControllerInterface, DSMath, DSAuth
* [ ] [code-review/TransferFeeControllerInterface.md](code-review/TransferFeeControllerInterface.md)
  * [ ] contract TransferFeeControllerInterface
* [ ] [code-review/dappsys.md](code-review/dappsys.md)
  * [x] contract DSMath
  * [x] contract ERC20Events
  * [x] contract ERC20 is ERC20Events
  * [x] contract DSAuthority
  * [x] contract DSAuthEvents
  * [x] contract DSAuth is DSAuthEvents
  * [x] contract DSNote
  * [x] contract DSStop is DSNote, DSAuth
  * [x] contract DSGuardEvents
  * [x] contract DSGuard is DSAuth, DSAuthority, DSGuardEvents
  * [x] contract DSGuardFactory
  * [ ] contract DSRoles is DSAuth, DSAuthority
  * [ ] contract DSTokenBase is ERC20, DSMath
  * [ ] contract DSToken is DSTokenBase(0), DSStop
  * [ ] contract DSMultiVault is DSAuth
  * [ ] contract DSVault is DSMultiVault
  * [ ] contract DSExec
  * [x] contract DSThing is DSAuth, DSNote, DSMath
* [ ] [code-review/solovault.md](code-review/solovault.md)
  * [ ] contract DSSoloVault is DSAuth

<br />

### Outside Scope

* [../../chain/contracts/Multisig.sol](../../chain/contracts/Multisig.sol) - **NOTE** *MultiSigWalletFactory* is included twice in this file






----------------------------------


# OneLedger Crowdsale Contract Audit

## Summary

[OneLedger](https://oneledger.io/) intends to run a crowdsale commencing on May 25 2018.

Bok Consulting Pty Ltd was commissioned to perform an audit on the Ethereum smart contracts for OneLedger's crowdsale.

This audit has been conducted on OneLedger's source code in commits
[0892237](https://github.com/Oneledger/OLT/commit/0892237bd158f483e3cc03bf975d49b2bf376c62),
[f1c5bb7](https://github.com/Oneledger/OLT/commit/f1c5bb7a439782a85204e9764598d695649098f4),
[ea16049](https://github.com/Oneledger/OLT/commit/ea160497e62fa84ac5d057ecaf3a43175f4d0d00),
[df0cd5d](https://github.com/Oneledger/OLT/commit/df0cd5d4eca6f2d216ffdea19e224ceda75e8e7a),
[c88c6c4](https://github.com/Oneledger/OLT/commit/c88c6c4dcfe30ec111abd1dcfb4b1c5427231148) and
[572e128](https://github.com/Oneledger/OLT/commit/572e128606be3fb3c03c38c8bd681848efd4d9f9).

No potential vulnerabilities have been identified in the crowdsale, token and vesting contracts.

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Recommendations](#recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Testing](#testing)
* [Code Review](#code-review)

<br />

<hr />

## Recommendations

* [x] **HIGH IMPORTANCE** A malicious third party can call `OneledgerTokenVesting.release(...)` with a token contract other than the real *OLT* token contract and deny the beneficiaries from ever receiving the real *OLT* tokens, as the `elapsedPeriods` variable can be made to update with the incorrect token contract
  * [x] Fixed in [ea16049](https://github.com/Oneledger/OLT/commit/ea160497e62fa84ac5d057ecaf3a43175f4d0d00)
* [x] **MEDIUM IMPORTANCE** To improve the security on the *OneledgerTokenVesting* contract, derive this class from *Ownable* and add `require(msg.sender == owner || msg.sender == beneficiary);` to  `OneledgerTokenVesting.release(...)`
  * [x] Updated in [df0cd5d](https://github.com/Oneledger/OLT/commit/df0cd5d4eca6f2d216ffdea19e224ceda75e8e7a)
* [x] **LOW IMPORTANCE** `OneledgerTokenVesting.getToken()` should be made a `view` function, or remove `getToken()` and make `token` public
  * [x] Fixed in [df0cd5d](https://github.com/Oneledger/OLT/commit/df0cd5d4eca6f2d216ffdea19e224ceda75e8e7a)
* [x] **LOW IMPORTANCE** `OneledgerToken.decimals` returns the `uint256` data type instead of `uint8` as recommended in the [ERC20 token standard]
  * [x] Fixed in [df0cd5d](https://github.com/Oneledger/OLT/commit/df0cd5d4eca6f2d216ffdea19e224ceda75e8e7a)

<br />

<hr />

## Potential Vulnerabilities

No potential vulnerabilities have been identified in the crowdsale, token and vesting contracts.

<br />

<hr />

## Scope

This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds
contributed to these contracts are not easily attacked or stolen by third parties. The secondary aim of this audit is to
ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to
highlight any areas of weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the OneLedger's business proposition, the individuals
involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence

As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition
before funding any crowdsales.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on
the crowdsale beneficiary's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as
duplicating crowdsale websites. Potential participants should NOT just click on any links received through these messages.
Scammers have also hacked the crowdsale website to replace the crowdsale contract address with their scam address.

Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address
matches the audited source code, and that the deployment parameters are correctly set, including the constant parameters.

<br />

<hr />

## Risks

Ethers contributed to the crowdsale contract are transferred directly to the crowdsale wallet, and tokens are generated for the contributing account. This reduces the severity of any attacks on the crowdsale contract.

The token contract is a simple extension of the OpenZeppelin library token contract that is used by many other tokens.

Once the vesting contract is deployed, and tokens transferred to the vesting contract, only the beneficiary or the vesting contract owner is able to execute the token release function when the tokens are vested.

<br />

<hr />

## Testing

Details of the testing environment can be found in [test](test).

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy crowdsale contract
  * [x] Deploy token contract
* [x] Whitelist accounts
* [x] Contribute to the crowdsale contract during the 1st whitelist period with amount <= whitelisted amount
* [x] Contribute to the crowdsale contract during the 1st whitelist period with amount <= whitelisted amount and rejecting double contributions
* [x] Contribute to the crowdsale contract during the 2nd whitelist period with amount <= 2 x whitelisted amount
* [x] Contribute to the crowdsale contract after the 2nd whitelist period with no whitelisted amount limits
* [x] Crowdsale owner mint tokens
* [x] Finalise crowdsale
* [x] `transfer(...)`, `approve(...)` and `transferFrom(...)`
* [x] Deploy vesting contract
* [x] Transfer tokens to the vesting contract
* [x] Beneficiary execute vesting token release function
* [x] Vesting contract owner execute vesting token release function

<br />

<hr />

## Code Review

* [x] [code-review/ICO.md](code-review/ICO.md)
  * [x] contract ICO is Ownable
    * [x] using SafeMath for uint256;
* [x] [code-review/OneledgerToken.md](code-review/OneledgerToken.md)
  * [x] contract OneledgerToken is MintableToken
    * [x] using SafeMath for uint256;
* [x] [code-review/OneledgerTokenVesting.md](code-review/OneledgerTokenVesting.md)
  * [x] contract OneledgerTokenVesting
    * [x] using SafeMath for uint256;

<br />

### OpenZeppelin 1.10.0 Dependencies

The version of OpenZeppelin was upgrade from 1.8.0 to 1.10.0 in [572e128](https://github.com/Oneledger/OLT/commit/572e128606be3fb3c03c38c8bd681848efd4d9f9).

* [x] [openzeppelin-code-review/math/SafeMath.md](openzeppelin-code-review/math/SafeMath.md)
  * [x] library SafeMath
* [x] [openzeppelin-code-review/ownership/Ownable.md](openzeppelin-code-review/ownership/Ownable.md)
  * [x] contract Ownable
* [x] [openzeppelin-code-review/token/ERC20/ERC20Basic.md](openzeppelin-code-review/token/ERC20/ERC20Basic.md)
  * [x] contract ERC20Basic
* [x] [openzeppelin-code-review/token/ERC20/ERC20.md](openzeppelin-code-review/token/ERC20/ERC20.md)
  * [x] contract ERC20 is ERC20Basic
* [x] [openzeppelin-code-review/token/ERC20/BasicToken.md](openzeppelin-code-review/token/ERC20/BasicToken.md)
  * [x] contract BasicToken is ERC20Basic
    * [x] using SafeMath for uint256;
* [x] [openzeppelin-code-review/token/ERC20/StandardToken.md](openzeppelin-code-review/token/ERC20/StandardToken.md)
  * [x] contract StandardToken is ERC20, BasicToken
* [x] [openzeppelin-code-review/token/ERC20/MintableToken.md](openzeppelin-code-review/token/ERC20/MintableToken.md)
  * [x] contract MintableToken is StandardToken, Ownable

<br />

### Excluded - Only Used For Testing

* [../contracts/Migrations.sol](../contracts/Migrations.sol)

<br />

<br />

(c) Adrian Guerrera / Deepyr Pty Ltd for OAX Swim Gateway - Aug 14 2018. The MIT Licence.
(c) BokkyPooBah / Bok Consulting Pty Ltd for OAX Swim Gateway - Aug 14 2018. The MIT Licence.

[ERC20 token standard]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
