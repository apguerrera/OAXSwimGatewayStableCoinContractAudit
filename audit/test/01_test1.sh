#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------


brew install https://raw.githubusercontent.com/ethereum/homebrew-ethereum/9c1da746bbfc9e60831d37d01436a41f4464f0e1/solidity.rb

source settings
echo "---------- Settings ----------" | tee $TEST1OUTPUT
cat ./settings | tee -a $TEST1OUTPUT
echo "" | tee -a $TEST1OUTPUT

CURRENTTIME=`date +%s`
CURRENTTIMES=`perl -le "print scalar localtime $CURRENTTIME"`
START_DATE=`echo "$CURRENTTIME+45" | bc`
START_DATE_S=`perl -le "print scalar localtime $START_DATE"`
END_DATE=`echo "$CURRENTTIME+60*2" | bc`
END_DATE_S=`perl -le "print scalar localtime $END_DATE"`

printf "CURRENTTIME               = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "START_DATE                = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "END_DATE                  = '$END_DATE' '$END_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file ---
# rsync -rp $SOURCEDIR/* . --exclude=Multisig.sol --exclude=test/
rsync -rp $SOURCEDIR/* . --exclude=Multisig.sol
# Copy modified contracts if any files exist
find ./modifiedContracts -type f -name \* -exec cp {} . \;

# --- Modify parameters ---
`perl -pi -e "s/AddressControlStatus addressControlStatus;/AddressControlStatus public addressControlStatus;/" Kyc.sol`
`perl -pi -e "s/KycAmlStatus kycAmlStatus;/KycAmlStatus public kycAmlStatus;/" Kyc.sol`
`perl -pi -e "s/MembershipAuthorityInterface membershipAuthority;/MembershipAuthorityInterface public membershipAuthority;/" Kyc.sol`
`perl -pi -e "s/uint256 private defaultDelayHours;/uint256 public defaultDelayHours;/" LimitSetting.sol`
`perl -pi -e "s/uint256 private defaultDelayHoursBuffer;/uint256 public defaultDelayHoursBuffer;/" LimitSetting.sol`
`perl -pi -e "s/uint256 private lastDefaultDelayHoursSettingResetTime;/uint256 public lastDefaultDelayHoursSettingResetTime;/" LimitSetting.sol`
`perl -pi -e "s/uint256 private defaultMintDailyLimit;/uint256 public defaultMintDailyLimit;/" LimitSetting.sol`
`perl -pi -e "s/uint256 private defaultBurnDailyLimit;/uint256 public defaultBurnDailyLimit;/" LimitSetting.sol`
`perl -pi -e "s/uint256 private defaultMintDailyLimitBuffer;/uint256 public defaultMintDailyLimitBuffer;/" LimitSetting.sol`
`perl -pi -e "s/uint256 private defaultBurnDailyLimitBuffer;/uint256 public defaultBurnDailyLimitBuffer;/" LimitSetting.sol`
`perl -pi -e "s/LimitSetting limitSetting;/LimitSetting public limitSetting;/" LimitController.sol`
`perl -pi -e "s/TransferFeeController transferFeeController;/TransferFeeController public transferFeeController;/" GateWithFee.sol`

DIFFS1=`diff -r -x '*.js' -x '*.json' -x '*.txt' -x 'testchain' -x '*.md -x' -x '*.sh' -x 'settings' -x 'modifiedContracts' $SOURCEDIR .`
echo "--- Differences $SOURCEDIR/*.sol *.sol ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT


solc --version | tee -a $TEST1OUTPUT

echo "var gateRolesOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $GATEROLESSOL`;" > $GATEROLESJS
echo "var dappsysOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $DAPPSYSSOL`;" > $DAPPSYSJS
echo "var kycOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $KYCSOL`;" > $KYCJS
echo "var transferFeeControllerOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $TRANSFERFEECONTROLLERSOL`;" > $TRANSFERFEECONTROLLERJS
echo "var limitSettingOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $LIMITSETTINGSOL`;" > $LIMITSETTINGJS
echo "var membershipAuthorityOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $MEMBERSHIPAUTHORITYSOL`;" > $MEMBERSHIPAUTHORITYJS
echo "var limitControllerOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $LIMITCONTROLLERSOL`;" > $LIMITCONTROLLERJS
echo "var fiatTokenOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $FIATTOKENSOL`;" > $FIATTOKENJS
echo "var gateWithFeeOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $GATEWITHFEESOL`;" > $GATEWITHFEEJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$GATEROLESJS");
loadScript("$DAPPSYSJS");
loadScript("$KYCJS");
loadScript("$TRANSFERFEECONTROLLERJS");
loadScript("$LIMITSETTINGJS");
loadScript("$MEMBERSHIPAUTHORITYJS");
loadScript("$LIMITCONTROLLERJS");
loadScript("$FIATTOKENJS");
loadScript("$GATEWITHFEEJS");
loadScript("lookups.js");
loadScript("functions.js");

var gateRolesAbi = JSON.parse(gateRolesOutput.contracts["$GATEROLESSOL:GateRoles"].abi);
var gateRolesBin = "0x" + gateRolesOutput.contracts["$GATEROLESSOL:GateRoles"].bin;
var fiatTokenGuardAbi = JSON.parse(dappsysOutput.contracts["$DAPPSYSSOL:DSGuard"].abi);
var fiatTokenGuardBin = "0x" + dappsysOutput.contracts["$DAPPSYSSOL:DSGuard"].bin;
var kycAmlStatusAbi = JSON.parse(kycOutput.contracts["$KYCSOL:KycAmlStatus"].abi);
var kycAmlStatusBin = "0x" + kycOutput.contracts["$KYCSOL:KycAmlStatus"].bin;
var addressControlStatusAbi = JSON.parse(kycOutput.contracts["$KYCSOL:AddressControlStatus"].abi);
var addressControlStatusBin = "0x" + kycOutput.contracts["$KYCSOL:AddressControlStatus"].bin;
var transferFeeControllerAbi = JSON.parse(transferFeeControllerOutput.contracts["$TRANSFERFEECONTROLLERSOL:TransferFeeController"].abi);
var transferFeeControllerBin = "0x" + transferFeeControllerOutput.contracts["$TRANSFERFEECONTROLLERSOL:TransferFeeController"].bin;
var limitSettingAbi = JSON.parse(limitSettingOutput.contracts["$LIMITSETTINGSOL:LimitSetting"].abi);
var limitSettingBin = "0x" + limitSettingOutput.contracts["$LIMITSETTINGSOL:LimitSetting"].bin;
var noKycAmlRuleAbi = JSON.parse(kycOutput.contracts["$KYCSOL:NoKycAmlRule"].abi);
var noKycAmlRuleBin = "0x" + kycOutput.contracts["$KYCSOL:NoKycAmlRule"].bin;
var boundaryKycAmlRuleAbi = JSON.parse(kycOutput.contracts["$KYCSOL:BoundaryKycAmlRule"].abi);
var boundaryKycAmlRuleBin = "0x" + kycOutput.contracts["$KYCSOL:BoundaryKycAmlRule"].bin;
var fullKycAmlRuleAbi = JSON.parse(kycOutput.contracts["$KYCSOL:FullKycAmlRule"].abi);
var fullKycAmlRuleBin = "0x" + kycOutput.contracts["$KYCSOL:FullKycAmlRule"].bin;
var mockMembershipAuthorityAbi = JSON.parse(membershipAuthorityOutput.contracts["$MEMBERSHIPAUTHORITYSOL:MockMembershipAuthority"].abi);
var mockMembershipAuthorityBin = "0x" + membershipAuthorityOutput.contracts["$MEMBERSHIPAUTHORITYSOL:MockMembershipAuthority"].bin;
var membershipWithBoundaryKycAmlRuleAbi = JSON.parse(kycOutput.contracts["$KYCSOL:MembershipWithBoundaryKycAmlRule"].abi);
var membershipWithBoundaryKycAmlRuleBin = "0x" + kycOutput.contracts["$KYCSOL:MembershipWithBoundaryKycAmlRule"].bin;
var limitControllerAbi = JSON.parse(limitControllerOutput.contracts["$LIMITCONTROLLERSOL:LimitController"].abi);
var limitControllerBin = "0x" + limitControllerOutput.contracts["$LIMITCONTROLLERSOL:LimitController"].bin;
var fiatTokenAbi = JSON.parse(fiatTokenOutput.contracts["$FIATTOKENSOL:FiatToken"].abi);
var fiatTokenBin = "0x" + fiatTokenOutput.contracts["$FIATTOKENSOL:FiatToken"].bin;
var gateWithFeeAbi = JSON.parse(gateWithFeeOutput.contracts["$GATEWITHFEESOL:GateWithFee"].abi);
var gateWithFeeBin = "0x" + gateWithFeeOutput.contracts["$GATEWITHFEESOL:GateWithFee"].bin;

// console.log("DATA: gateRolesAbi=" + JSON.stringify(gateRolesAbi));
// console.log("DATA: gateRolesBin=" + JSON.stringify(gateRolesBin));
// console.log("DATA: fiatTokenGuardAbi=" + JSON.stringify(fiatTokenGuardAbi));
// console.log("DATA: fiatTokenGuardBin=" + JSON.stringify(fiatTokenGuardBin));
// console.log("DATA: kycAmlStatusAbi=" + JSON.stringify(kycAmlStatusAbi));
// console.log("DATA: kycAmlStatusBin=" + JSON.stringify(kycAmlStatusBin));
// console.log("DATA: addressControlStatusAbi=" + JSON.stringify(addressControlStatusAbi));
// console.log("DATA: addressControlStatusBin=" + JSON.stringify(addressControlStatusBin));
// console.log("DATA: transferFeeControllerAbi=" + JSON.stringify(transferFeeControllerAbi));
// console.log("DATA: transferFeeControllerBin=" + JSON.stringify(transferFeeControllerBin));
// console.log("DATA: limitSettingAbi=" + JSON.stringify(limitSettingAbi));
// console.log("DATA: limitSettingBin=" + JSON.stringify(limitSettingBin));
// console.log("DATA: noKycAmlRuleAbi=" + JSON.stringify(noKycAmlRuleAbi));
// console.log("DATA: noKycAmlRuleBin=" + JSON.stringify(noKycAmlRuleBin));
// console.log("DATA: boundaryKycAmlRuleAbi=" + JSON.stringify(boundaryKycAmlRuleAbi));
// console.log("DATA: boundaryKycAmlRuleBin=" + JSON.stringify(boundaryKycAmlRuleBin));
// console.log("DATA: fullKycAmlRuleAbi=" + JSON.stringify(fullKycAmlRuleAbi));
// console.log("DATA: fullKycAmlRuleBin=" + JSON.stringify(fullKycAmlRuleBin));
// console.log("DATA: mockMembershipAuthorityAbi=" + JSON.stringify(mockMembershipAuthorityAbi));
// console.log("DATA: mockMembershipAuthorityBin=" + JSON.stringify(mockMembershipAuthorityBin));
// console.log("DATA: membershipWithBoundaryKycAmlRuleAbi=" + JSON.stringify(membershipWithBoundaryKycAmlRuleAbi));
// console.log("DATA: membershipWithBoundaryKycAmlRuleBin=" + JSON.stringify(membershipWithBoundaryKycAmlRuleBin));
// console.log("DATA: limitControllerAbi=" + JSON.stringify(limitControllerAbi));
// console.log("DATA: limitControllerBin=" + JSON.stringify(limitControllerBin));
// console.log("DATA: fiatTokenAbi=" + JSON.stringify(fiatTokenAbi));
// console.log("DATA: fiatTokenBin=" + JSON.stringify(fiatTokenBin));
// console.log("DATA: gateWithFeeAbi=" + JSON.stringify(gateWithFeeAbi));
// console.log("DATA: gateWithFeeBin=" + JSON.stringify(gateWithFeeBin));


unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployGroup1Message = "Deploy Group #1";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployGroup1Message + " ----------");
var gateRolesContract = web3.eth.contract(gateRolesAbi);
var gateRolesTx = null;
var gateRolesAddress = null;
var gateRoles = gateRolesContract.new({from: deployer, data: gateRolesBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        gateRolesTx = contract.transactionHash;
      } else {
        gateRolesAddress = contract.address;
        addAccount(gateRolesAddress, "GateRoles");
        addGateRolesContractAddressAndAbi(gateRolesAddress, gateRolesAbi);
        console.log("DATA: var gateRolesAddress=\"" + gateRolesAddress + "\";");
        console.log("DATA: var gateRolesAbi=" + JSON.stringify(gateRolesAbi) + ";");
        console.log("DATA: var gateRoles=eth.contract(gateRolesAbi).at(gateRolesAddress);");
      }
    }
  }
);
var fiatTokenGuardContract = web3.eth.contract(fiatTokenGuardAbi);
var fiatTokenGuardTx = null;
var fiatTokenGuardAddress = null;
var fiatTokenGuard = fiatTokenGuardContract.new({from: deployer, data: fiatTokenGuardBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        fiatTokenGuardTx = contract.transactionHash;
      } else {
        fiatTokenGuardAddress = contract.address;
        addAccount(fiatTokenGuardAddress, "FiatTokenGuard");
        addTokenGuardContractAddressAndAbi(fiatTokenGuardAddress, fiatTokenGuardAbi);
        console.log("DATA: var fiatTokenGuardAddress=\"" + fiatTokenGuardAddress + "\";");
        console.log("DATA: var fiatTokenGuardAbi=" + JSON.stringify(fiatTokenGuardAbi) + ";");
        console.log("DATA: var fiatTokenGuard=eth.contract(fiatTokenGuardAbi).at(fiatTokenGuardAddress);");
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(gateRolesTx, deployGroup1Message + " - GateRoles");
failIfTxStatusError(fiatTokenGuardTx, deployGroup1Message + " - FiatTokenGuard");
printTxData("gateRolesTx", gateRolesTx);
printTxData("fiatTokenGuardTx", fiatTokenGuardTx);
printGateRolesContractDetails();
printTokenGuardContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployGroup2Message = "Deploy Group #2";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployGroup2Message + " ----------");
var kycAmlStatusContract = web3.eth.contract(kycAmlStatusAbi);
var kycAmlStatusTx = null;
var kycAmlStatusAddress = null;
var kycAmlStatus = kycAmlStatusContract.new(gateRolesAddress, {from: deployer, data: kycAmlStatusBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        kycAmlStatusTx = contract.transactionHash;
      } else {
        kycAmlStatusAddress = contract.address;
        addAccount(kycAmlStatusAddress, "KycAmlStatus");
        addKycAmlStatusContractAddressAndAbi(kycAmlStatusAddress, kycAmlStatusAbi);
        console.log("DATA: var kycAmlStatusAddress=\"" + kycAmlStatusAddress + "\";");
        console.log("DATA: var kycAmlStatusAbi=" + JSON.stringify(kycAmlStatusAbi) + ";");
        console.log("DATA: var kycAmlStatus=eth.contract(kycAmlStatusAbi).at(kycAmlStatusAddress);");
      }
    }
  }
);
var addressControlStatusContract = web3.eth.contract(addressControlStatusAbi);
var addressControlStatusTx = null;
var addressControlStatusAddress = null;
var addressControlStatus = addressControlStatusContract.new(gateRolesAddress, {from: deployer, data: addressControlStatusBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        addressControlStatusTx = contract.transactionHash;
      } else {
        addressControlStatusAddress = contract.address;
        addAccount(addressControlStatusAddress, "AddressControlStatus");
        addAddressControlStatusContractAddressAndAbi(addressControlStatusAddress, addressControlStatusAbi);
        console.log("DATA: var addressControlStatusAddress=\"" + addressControlStatusAddress + "\";");
        console.log("DATA: var addressControlStatusAbi=" + JSON.stringify(addressControlStatusAbi) + ";");
        console.log("DATA: var addressControlStatus=eth.contract(addressControlStatusAbi).at(addressControlStatusAddress);");
      }
    }
  }
);
var transferFeeControllerContract = web3.eth.contract(transferFeeControllerAbi);
var transferFeeControllerTx = null;
var transferFeeControllerAddress = null;
var transferFeeController = transferFeeControllerContract.new(gateRolesAddress, 0, 0, {from: deployer, data: transferFeeControllerBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        transferFeeControllerTx = contract.transactionHash;
      } else {
        transferFeeControllerAddress = contract.address;
        addAccount(transferFeeControllerAddress, "TransferFeeController");
        addTransferFeeControllerContractAddressAndAbi(transferFeeControllerAddress, transferFeeControllerAbi);
        console.log("DATA: var transferFeeControllerAddress=\"" + transferFeeControllerAddress + "\";");
        console.log("DATA: var transferFeeControllerAbi=" + JSON.stringify(transferFeeControllerAbi) + ";");
        console.log("DATA: var transferFeeController=eth.contract(transferFeeControllerAbi).at(transferFeeControllerAddress);");
      }
    }
  }
);
var limitSettingContract = web3.eth.contract(limitSettingAbi);
var limitSettingTx = null;
var limitSettingAddress = null;
var limitSetting = limitSettingContract.new(gateRolesAddress, $MINT_LIMIT, $BURN_LIMIT, $DEFAULT_LIMIT_COUNTER_RESET_TIME_OFFSET, $DEFAULT_SETTING_DELAY_HOURS, {from: deployer, data: limitSettingBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        limitSettingTx = contract.transactionHash;
      } else {
        limitSettingAddress = contract.address;
        addAccount(limitSettingAddress, "LimitSetting");
        addLimitSettingContractAddressAndAbi(limitSettingAddress, limitSettingAbi);
        console.log("DATA: var limitSettingAddress=\"" + limitSettingAddress + "\";");
        console.log("DATA: var limitSettingAbi=" + JSON.stringify(limitSettingAbi) + ";");
        console.log("DATA: var limitSetting=eth.contract(limitSettingAbi).at(limitSettingAddress);");
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(kycAmlStatusTx, deployGroup2Message + " - KycAmlStatus");
failIfTxStatusError(addressControlStatusTx, deployGroup2Message + " - AddressControlStatus");
failIfTxStatusError(transferFeeControllerTx, deployGroup2Message + " - TransferFeeController");
failIfTxStatusError(limitSettingTx, deployGroup2Message + " - LimitSetting");
printTxData("kycAmlStatusTx", kycAmlStatusTx);
printTxData("addressControlStatusTx", addressControlStatusTx);
printTxData("transferFeeControllerTx", transferFeeControllerTx);
printTxData("limitSettingTx", limitSettingTx);
printKycAmlStatusContractDetails();
printAddressControlStatusContractDetails();
printTransferFeeControllerContractDetails();
printLimitSettingContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployGroup3Message = "Deploy Group #3";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployGroup3Message + " ----------");
var noKycAmlRuleContract = web3.eth.contract(noKycAmlRuleAbi);
var noKycAmlRuleTx = null;
var noKycAmlRuleAddress = null;
var noKycAmlRule = noKycAmlRuleContract.new(addressControlStatusAddress, {from: deployer, data: noKycAmlRuleBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        noKycAmlRuleTx = contract.transactionHash;
      } else {
        noKycAmlRuleAddress = contract.address;
        addAccount(noKycAmlRuleAddress, "NoKycAmlRule");
        addNoKycAmlRuleContractAddressAndAbi(noKycAmlRuleAddress, noKycAmlRuleAbi);
        console.log("DATA: var noKycAmlRuleAddress=\"" + noKycAmlRuleAddress + "\";");
        console.log("DATA: var noKycAmlRuleAbi=" + JSON.stringify(noKycAmlRuleAbi) + ";");
        console.log("DATA: var noKycAmlRule=eth.contract(noKycAmlRuleAbi).at(noKycAmlRuleAddress);");
      }
    }
  }
);
var boundaryKycAmlRuleContract = web3.eth.contract(boundaryKycAmlRuleAbi);
var boundaryKycAmlRuleTx = null;
var boundaryKycAmlRuleAddress = null;
var boundaryKycAmlRule = boundaryKycAmlRuleContract.new(addressControlStatusAddress, kycAmlStatusAddress, {from: deployer, data: boundaryKycAmlRuleBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        boundaryKycAmlRuleTx = contract.transactionHash;
      } else {
        boundaryKycAmlRuleAddress = contract.address;
        addAccount(boundaryKycAmlRuleAddress, "BoundaryKycAmlRule");
        addBoundaryKycAmlRuleContractAddressAndAbi(boundaryKycAmlRuleAddress, boundaryKycAmlRuleAbi);
        console.log("DATA: var boundaryKycAmlRuleAddress=\"" + boundaryKycAmlRuleAddress + "\";");
        console.log("DATA: var boundaryKycAmlRuleAbi=" + JSON.stringify(boundaryKycAmlRuleAbi) + ";");
        console.log("DATA: var boundaryKycAmlRule=eth.contract(boundaryKycAmlRuleAbi).at(boundaryKycAmlRuleAddress);");
      }
    }
  }
);
var fullKycAmlRuleContract = web3.eth.contract(fullKycAmlRuleAbi);
var fullKycAmlRuleTx = null;
var fullKycAmlRuleAddress = null;
var fullKycAmlRule = fullKycAmlRuleContract.new(addressControlStatusAddress, kycAmlStatusAddress, {from: deployer, data: fullKycAmlRuleBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        fullKycAmlRuleTx = contract.transactionHash;
      } else {
        fullKycAmlRuleAddress = contract.address;
        addAccount(fullKycAmlRuleAddress, "FullKycAmlRule");
        addFullKycAmlRuleContractAddressAndAbi(fullKycAmlRuleAddress, fullKycAmlRuleAbi);
        console.log("DATA: var fullKycAmlRuleAddress=\"" + fullKycAmlRuleAddress + "\";");
        console.log("DATA: var fullKycAmlRuleAbi=" + JSON.stringify(fullKycAmlRuleAbi) + ";");
        console.log("DATA: var fullKycAmlRule=eth.contract(fullKycAmlRuleAbi).at(fullKycAmlRuleAddress);");
      }
    }
  }
);
var mockMembershipAuthorityContract = web3.eth.contract(mockMembershipAuthorityAbi);
var mockMembershipAuthorityTx = null;
var mockMembershipAuthorityAddress = null;
var mockMembershipAuthority = mockMembershipAuthorityContract.new({from: deployer, data: mockMembershipAuthorityBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        mockMembershipAuthorityTx = contract.transactionHash;
      } else {
        mockMembershipAuthorityAddress = contract.address;
        addAccount(mockMembershipAuthorityAddress, "MockMembershipAuthority");
        // BK TODO
        console.log("DATA: mockMembershipAuthorityAddress=\"" + mockMembershipAuthorityAddress + "\";");
        console.log("DATA: var mockMembershipAuthorityAddress=\"" + mockMembershipAuthorityAddress + "\";");
        console.log("DATA: var mockMembershipAuthorityAbi=" + JSON.stringify(mockMembershipAuthorityAbi) + ";");
        console.log("DATA: var mockMembershipAuthority=eth.contract(mockMembershipAuthorityAbi).at(mockMembershipAuthorityAddress);");
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
var membershipWithBoundaryKycAmlRuleContract = web3.eth.contract(membershipWithBoundaryKycAmlRuleAbi);
var membershipWithBoundaryKycAmlRuleTx = null;
var membershipWithBoundaryKycAmlRuleAddress = null;
var membershipWithBoundaryKycAmlRule = membershipWithBoundaryKycAmlRuleContract.new(gateRolesAddress, addressControlStatusAddress, kycAmlStatusAddress, mockMembershipAuthorityAddress, {from: deployer, data: membershipWithBoundaryKycAmlRuleBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        membershipWithBoundaryKycAmlRuleTx = contract.transactionHash;
      } else {
        membershipWithBoundaryKycAmlRuleAddress = contract.address;
        addAccount(membershipWithBoundaryKycAmlRuleAddress, "MembershipWithBoundaryKycAmlRule");
        addMembershipWithBoundaryKycAmlRuleContractAddressAndAbi(membershipWithBoundaryKycAmlRuleAddress, membershipWithBoundaryKycAmlRuleAbi);
        console.log("DATA: var membershipWithBoundaryKycAmlRuleAddress=\"" + membershipWithBoundaryKycAmlRuleAddress + "\";");
        console.log("DATA: var membershipWithBoundaryKycAmlRuleAbi=" + JSON.stringify(membershipWithBoundaryKycAmlRuleAbi) + ";");
        console.log("DATA: var membershipWithBoundaryKycAmlRule=eth.contract(membershipWithBoundaryKycAmlRuleAbi).at(membershipWithBoundaryKycAmlRuleAddress);");
      }
    }
  }
);
var limitControllerContract = web3.eth.contract(limitControllerAbi);
var limitControllerTx = null;
var limitControllerAddress = null;
var limitController = limitControllerContract.new(fiatTokenGuardAddress, limitSettingAddress, {from: deployer, data: limitControllerBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        limitControllerTx = contract.transactionHash;
      } else {
        limitControllerAddress = contract.address;
        addAccount(limitControllerAddress, "LimitController");
        addLimitControllerContractAddressAndAbi(limitControllerAddress, limitControllerAbi);
        console.log("DATA: var limitControllerAddress=\"" + limitControllerAddress + "\";");
        console.log("DATA: var limitControllerAbi=" + JSON.stringify(limitControllerAbi) + ";");
        console.log("DATA: var limitController=eth.contract(limitControllerAbi).at(limitControllerAddress);");
      }
    }
  }
);
var fiatTokenContract = web3.eth.contract(fiatTokenAbi);
var fiatTokenTx = null;
var fiatTokenAddress = null;
var fiatToken = fiatTokenContract.new(fiatTokenGuardAddress, "USD", "USDToken", transferFeeCollector, transferFeeControllerAddress, {from: deployer, data: fiatTokenBin, gas: 2000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        fiatTokenTx = contract.transactionHash;
      } else {
        fiatTokenAddress = contract.address;
        addAccount(fiatTokenAddress, "FiatToken '" + web3.toUtf8(fiatToken.symbol()) + "' '" + web3.toUtf8(fiatToken.name()) + "'");
        addTokenAContractAddressAndAbi(fiatTokenAddress, fiatTokenAbi);
        console.log("DATA: var fiatTokenAddress=\"" + fiatTokenAddress + "\";");
        console.log("DATA: var fiatTokenAbi=" + JSON.stringify(fiatTokenAbi) + ";");
        console.log("DATA: var fiatToken=eth.contract(fiatTokenAbi).at(fiatTokenAddress);");
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(noKycAmlRuleTx, deployGroup3Message + " - NoKycAmlRule");
failIfTxStatusError(boundaryKycAmlRuleTx, deployGroup3Message + " - BoundaryKycAmlRule");
failIfTxStatusError(fullKycAmlRuleTx, deployGroup3Message + " - FullKycAmlRule");
failIfTxStatusError(mockMembershipAuthorityTx, deployGroup3Message + " - MockMembershipAuthority");
failIfTxStatusError(membershipWithBoundaryKycAmlRuleTx, deployGroup3Message + " - MembershipWithBoundaryKycAmlRule");
failIfTxStatusError(limitControllerTx, deployGroup3Message + " - LimitController");
failIfTxStatusError(fiatTokenTx, deployGroup3Message + " - FiatToken");
printTxData("noKycAmlRuleTx", noKycAmlRuleTx);
printTxData("boundaryKycAmlRuleTx", boundaryKycAmlRuleTx);
printTxData("fullKycAmlRuleTx", fullKycAmlRuleTx);
printTxData("mockMembershipAuthorityTx", mockMembershipAuthorityTx);
printTxData("membershipWithBoundaryKycAmlRuleTx", membershipWithBoundaryKycAmlRuleTx);
printTxData("limitControllerTx", limitControllerTx);
printTxData("fiatTokenTx", fiatTokenTx);
printNoKycAmlRuleContractDetails();
printBoundaryKycAmlRuleContractDetails();
printFullKycAmlRuleContractDetails();
printMembershipWithBoundaryKycAmlRuleContractDetails();
printLimitControllerContractDetails();
printTokenAContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setUserRoles1Message = "Set User Roles";
var SYSTEM_ADMIN_ROLE = gateRoles.SYSTEM_ADMIN();
var KYC_OPERATOR_ROLE = gateRoles.KYC_OPERATOR();
var MONEY_OPERATOR_ROLE = gateRoles.MONEY_OPERATOR();
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + setUserRoles1Message + " ----------");
var setUserRoles1_1Tx = gateRoles.setUserRole(sysAdmin, SYSTEM_ADMIN_ROLE, true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setUserRoles1_2Tx = gateRoles.setUserRole(kycOperator, KYC_OPERATOR_ROLE, true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setUserRoles1_3Tx = gateRoles.setUserRole(moneyOperator, MONEY_OPERATOR_ROLE, true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setUserRoles1_1Tx, setUserRoles1Message + " - setUserRole(sysAdmin, SYSTEM_ADMIN_ROLE, true)");
failIfTxStatusError(setUserRoles1_2Tx, setUserRoles1Message + " - setUserRole(kycOperator, KYC_OPERATOR_ROLE, true)");
failIfTxStatusError(setUserRoles1_3Tx, setUserRoles1Message + " - setUserRole(moneyOperator, MONEY_OPERATOR_ROLE, true)");
printTxData("setUserRoles1_1Tx", setUserRoles1_1Tx);
printTxData("setUserRoles1_2Tx", setUserRoles1_2Tx);
printTxData("setUserRoles1_3Tx", setUserRoles1_3Tx);
printGateRolesContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setRoleRules1Message = "Set Roles Rules #1";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + setRoleRules1Message + " ----------");
var setRoleRules1_1Tx = gateRoles.setRoleCapability(KYC_OPERATOR_ROLE, kycAmlStatusAddress, web3.sha3("setKycVerified(address,bool)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules1_2Tx = gateRoles.setRoleCapability(MONEY_OPERATOR_ROLE, addressControlStatusAddress, web3.sha3("freezeAddress(address)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules1_3Tx = gateRoles.setRoleCapability(MONEY_OPERATOR_ROLE, addressControlStatusAddress, web3.sha3("unfreezeAddress(address)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules1_4Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, limitSettingAddress, web3.sha3("setSettingDefaultDelayHours(uint256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules1_5Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, limitSettingAddress, web3.sha3("setLimitCounterResetTimeOffset(int256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules1_6Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, limitSettingAddress, web3.sha3("setDefaultMintDailyLimit(uint256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules1_7Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, limitSettingAddress, web3.sha3("setDefaultBurnDailyLimit(uint256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules1_8Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, limitSettingAddress, web3.sha3("setCustomMintDailyLimit(address,uint256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules1_9Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, limitSettingAddress, web3.sha3("setCustomBurnDailyLimit(address,uint256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules1_10Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, transferFeeControllerAddress, web3.sha3("setDefaultTransferFee(uint256,uint256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules1_11Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, membershipWithBoundaryKycAmlRuleAddress, web3.sha3("setMembershipAuthority(address)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setRoleRules1_1Tx, setRoleRules1Message + " - setRoleCapability(KYC_OPERATOR_ROLE, kycAmlStatusAddress, web3.sha3(\"setKycVerified(address,bool)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules1_2Tx, setRoleRules1Message + " - setRoleCapability(MONEY_OPERATOR_ROLE, addressControlStatusAddress, web3.sha3(\"freezeAddress(address)\").substring(0, 10), true");
failIfTxStatusError(setRoleRules1_3Tx, setRoleRules1Message + " - setRoleCapability(MONEY_OPERATOR_ROLE, addressControlStatusAddress, web3.sha3(\"unfreezeAddress(address)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules1_4Tx, setRoleRules1Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, limitSettingAddress, web3.sha3(\"setSettingDefaultDelayHours(uint256)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules1_5Tx, setRoleRules1Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, limitSettingAddress, web3.sha3(\"setLimitCounterResetTimeOffset(int256)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules1_6Tx, setRoleRules1Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, limitSettingAddress, web3.sha3(\"setDefaultMintDailyLimit(uint256)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules1_7Tx, setRoleRules1Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, limitSettingAddress, web3.sha3(\"setDefaultBurnDailyLimit(uint256)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules1_8Tx, setRoleRules1Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, limitSettingAddress, web3.sha3(\"setCustomMintDailyLimit(address,uint256)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules1_9Tx, setRoleRules1Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, limitSettingAddress, web3.sha3(\"setCustomBurnDailyLimit(address,uint256)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules1_10Tx, setRoleRules1Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, transferFeeControllerAddress, web3.sha3(\"setDefaultTransferFee(uint256,uint256)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules1_11Tx, setRoleRules1Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, membershipWithBoundaryKycAmlRuleAddress, web3.sha3(\"setMembershipAuthority(address)\").substring(0, 10), true)");
printTxData("setRoleRules1_1Tx", setRoleRules1_1Tx);
printTxData("setRoleRules1_2Tx", setRoleRules1_2Tx);
printTxData("setRoleRules1_3Tx", setRoleRules1_3Tx);
printTxData("setRoleRules1_4Tx", setRoleRules1_4Tx);
printTxData("setRoleRules1_5Tx", setRoleRules1_5Tx);
printTxData("setRoleRules1_6Tx", setRoleRules1_6Tx);
printTxData("setRoleRules1_7Tx", setRoleRules1_6Tx);
printTxData("setRoleRules1_8Tx", setRoleRules1_8Tx);
printTxData("setRoleRules1_9Tx", setRoleRules1_9Tx);
printTxData("setRoleRules1_10Tx", setRoleRules1_10Tx);
printTxData("setRoleRules1_11Tx", setRoleRules1_11Tx);
printGateRolesContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployGroup4Message = "Deploy Group #4";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployGroup2Message + " ----------");
var gateWithFeeContract = web3.eth.contract(gateWithFeeAbi);
var gateWithFeeTx = null;
var gateWithFeeAddress = null;
var gateWithFee = gateWithFeeContract.new(gateRolesAddress, fiatTokenAddress, limitControllerAddress, mintFeeCollector, burnFeeCollector, transferFeeControllerAddress, {from: deployer, data: gateWithFeeBin, gas: 4000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        gateWithFeeTx = contract.transactionHash;
      } else {
        gateWithFeeAddress = contract.address;
        addAccount(gateWithFeeAddress, "GateWithFee");
        addGateWithFeeContractAddressAndAbi(gateWithFeeAddress, gateWithFeeAbi);
        console.log("DATA: var gateWithFeeAddress=\"" + gateWithFeeAddress + "\";");
        console.log("DATA: var gateWithFeeAbi=" + JSON.stringify(gateWithFeeAbi) + ";");
        console.log("DATA: var gateWithFee=eth.contract(gateWithFeeAbi).at(gateWithFeeAddress);");
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(gateWithFeeTx, deployGroup4Message + " - GateWithFee");
printTxData("gateWithFeeTx", gateWithFeeTx);
printGateWithFeeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setRoleRules2Message = "Set Roles Rules #2";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + setRoleRules2Message + " ----------");
var setRoleRules2_1Tx = gateRoles.setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3("mint(uint256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_2Tx = gateRoles.setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3("mint(address,uint256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_3Tx = gateRoles.setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3("burn(uint256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_4Tx = gateRoles.setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3("burn(address,uint256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_5Tx = gateRoles.setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3("start()").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_6Tx = gateRoles.setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3("stop()").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_7Tx = gateRoles.setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3("startToken()").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_8Tx = gateRoles.setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3("stopToken()").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_9Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3("setERC20Authority(address)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_10Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3("setTokenAuthority(address)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_11Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3("setLimitController(address)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_12Tx = gateRoles.setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3("mintWithFee(address,uint256,uint256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_13Tx = gateRoles.setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3("burnWithFee(address,uint256,uint256)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_14Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3("setFeeCollector(address)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_15Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3("setTransferFeeCollector(address)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_16Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3("setTransferFeeController(address)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_17Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3("setMintFeeCollector(address)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setRoleRules2_18Tx = gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3("setBurnFeeCollector(address)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice})
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setRoleRules2_1Tx, setRoleRules2Message + " - setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3(\"mint(uint256)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_2Tx, setRoleRules2Message + " - setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3(\"mint(address,uint256)\").substring(0, 10), true");
failIfTxStatusError(setRoleRules2_3Tx, setRoleRules2Message + " - setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3(\"burn(uint256)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_4Tx, setRoleRules2Message + " - setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3(\"burn(address,uint256)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_5Tx, setRoleRules2Message + " - setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3(\"start()\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_6Tx, setRoleRules2Message + " - setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3(\"stop()\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_7Tx, setRoleRules2Message + " - setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3(\"startToken()\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_8Tx, setRoleRules2Message + " - setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3(\"stopToken()\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_9Tx, setRoleRules2Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3(\"setERC20Authority(address)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_10Tx, setRoleRules2Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3(\"setTokenAuthority(address)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_11Tx, setRoleRules2Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3(\"setLimitController(address)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_12Tx, setRoleRules2Message + " - setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3(\"mintWithFee(address,uint256,uint256)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_13Tx, setRoleRules2Message + " - setRoleCapability(MONEY_OPERATOR_ROLE, gateWithFeeAddress, web3.sha3(\"burnWithFee(address,uint256,uint256)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_14Tx, setRoleRules2Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3(\"setFeeCollector(address)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_15Tx, setRoleRules2Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3(\"setTransferFeeCollector(address)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_16Tx, setRoleRules2Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3(\"setTransferFeeController(address)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_17Tx, setRoleRules2Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3(\"setMintFeeCollector(address)\").substring(0, 10), true)");
failIfTxStatusError(setRoleRules2_18Tx, setRoleRules2Message + " - setRoleCapability(SYSTEM_ADMIN_ROLE, gateWithFeeAddress, web3.sha3(\"setBurnFeeCollector(address)\").substring(0, 10), true)");
printTxData("setRoleRules2_1Tx", setRoleRules2_1Tx);
printTxData("setRoleRules2_2Tx", setRoleRules2_2Tx);
printTxData("setRoleRules2_3Tx", setRoleRules2_3Tx);
printTxData("setRoleRules2_4Tx", setRoleRules2_4Tx);
printTxData("setRoleRules2_5Tx", setRoleRules2_5Tx);
printTxData("setRoleRules2_6Tx", setRoleRules2_6Tx);
printTxData("setRoleRules2_7Tx", setRoleRules2_6Tx);
printTxData("setRoleRules2_8Tx", setRoleRules2_8Tx);
printTxData("setRoleRules2_9Tx", setRoleRules2_9Tx);
printTxData("setRoleRules2_10Tx", setRoleRules2_10Tx);
printTxData("setRoleRules2_11Tx", setRoleRules2_11Tx);
printTxData("setRoleRules2_12Tx", setRoleRules2_11Tx);
printTxData("setRoleRules2_13Tx", setRoleRules2_11Tx);
printTxData("setRoleRules2_14Tx", setRoleRules2_11Tx);
printTxData("setRoleRules2_15Tx", setRoleRules2_11Tx);
printTxData("setRoleRules2_16Tx", setRoleRules2_11Tx);
printTxData("setRoleRules2_17Tx", setRoleRules2_11Tx);
printTxData("setRoleRules2_18Tx", setRoleRules2_11Tx);
printGateRolesContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setGuardRules1Message = "Set Guard Rules #1";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + setGuardRules1Message + " ----------");
var setGuardRules1_1Tx = fiatTokenGuard.permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3("setName(bytes32)").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setGuardRules1_2Tx = fiatTokenGuard.permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3("mint(uint256)").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setGuardRules1_3Tx = fiatTokenGuard.permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3("mint(address,uint256)").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setGuardRules1_4Tx = fiatTokenGuard.permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3("burn(uint256)").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setGuardRules1_5Tx = fiatTokenGuard.permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3("burn(address,uint256)").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setGuardRules1_6Tx = fiatTokenGuard.permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3("setERC20Authority(address)").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setGuardRules1_7Tx = fiatTokenGuard.permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3("setTokenAuthority(address)").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setGuardRules1_8Tx = fiatTokenGuard.permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3("start()").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setGuardRules1_9Tx = fiatTokenGuard.permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3("stop()").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setGuardRules1_10Tx = fiatTokenGuard.permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3("setTransferFeeCollector(address)").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setGuardRules1_11Tx = fiatTokenGuard.permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3("setTransferFeeController(address)").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setGuardRules1_12Tx = fiatTokenGuard.permit(gateWithFeeAddress, limitControllerAddress, web3.sha3("bumpMintLimitCounter(uint256)").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
var setGuardRules1_13Tx = fiatTokenGuard.permit(gateWithFeeAddress, limitControllerAddress, web3.sha3("bumpBurnLimitCounter(uint256)").substring(0, 10), {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setGuardRules1_1Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3(\"setName(bytes32)\").substring(0, 10), true)");
failIfTxStatusError(setGuardRules1_2Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3(\"mint(uint256)\").substring(0, 10), true");
failIfTxStatusError(setGuardRules1_3Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3(\"mint(address,uint256)\").substring(0, 10), true)");
failIfTxStatusError(setGuardRules1_4Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3(\"burn(uint256)\").substring(0, 10), true)");
failIfTxStatusError(setGuardRules1_5Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3(\"burn(address,uint256)\").substring(0, 10), true)");
failIfTxStatusError(setGuardRules1_6Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3(\"setERC20Authority(address)\").substring(0, 10), true)");
failIfTxStatusError(setGuardRules1_7Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3(\"setTokenAuthority(address)\").substring(0, 10), true)");
failIfTxStatusError(setGuardRules1_8Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3(\"start()\").substring(0, 10), true)");
failIfTxStatusError(setGuardRules1_9Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3(\"stop()\").substring(0, 10), true)");
failIfTxStatusError(setGuardRules1_10Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3(\"setTransferFeeCollector(address)\").substring(0, 10), true)");
failIfTxStatusError(setGuardRules1_11Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, fiatTokenAddress, web3.sha3(\"setTransferFeeController(address)\").substring(0, 10), true)");
failIfTxStatusError(setGuardRules1_12Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, limitControllerAddress, web3.sha3(\"bumpMintLimitCounter(uint256)\").substring(0, 10), true)");
failIfTxStatusError(setGuardRules1_13Tx, setGuardRules1Message + " - permit(gateWithFeeAddress, limitControllerAddress, web3.sha3(\"bumpBurnLimitCounter(uint256)\").substring(0, 10), true)");
printTxData("setGuardRules1_1Tx", setGuardRules1_1Tx);
printTxData("setGuardRules1_2Tx", setGuardRules1_2Tx);
printTxData("setGuardRules1_3Tx", setGuardRules1_3Tx);
printTxData("setGuardRules1_4Tx", setGuardRules1_4Tx);
printTxData("setGuardRules1_5Tx", setGuardRules1_5Tx);
printTxData("setGuardRules1_6Tx", setGuardRules1_6Tx);
printTxData("setGuardRules1_7Tx", setGuardRules1_6Tx);
printTxData("setGuardRules1_8Tx", setGuardRules1_8Tx);
printTxData("setGuardRules1_9Tx", setGuardRules1_9Tx);
printTxData("setGuardRules1_10Tx", setGuardRules1_10Tx);
printTxData("setGuardRules1_11Tx", setGuardRules1_11Tx);
printTxData("setGuardRules1_12Tx", setGuardRules1_11Tx);
printTxData("setGuardRules1_13Tx", setGuardRules1_11Tx);
printTokenGuardContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transferOwnership11Message = "Transfer Ownership #1";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + transferOwnership11Message + " ----------");
var transferOwnership11_1Tx = gateRoles.setOwner(sysAdmin, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(transferOwnership11_1Tx, transferOwnership11Message + " - gateRoles.setOwner(sysAdmin)");
printTxData("transferOwnership11_1Tx", transferOwnership11_1Tx);
printGateRolesContractDetails();
console.log("RESULT: ");

// -----------------------------------------------------------------------------
var transferOwnership2Message = "Transfer Ownership #2";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + transferOwnership2Message + " ----------");
var transferOwnership2_1Tx = gateWithFee.setMintFeeCollector(sysAdmin, {from: sysAdmin, gas: 400000, gasPrice: defaultGasPrice});
var transferOwnership2_1Output =gateWithFee.mintFeeCollector();
var transferOwnership2_2Tx = gateWithFee.setMintFeeCollector(mintFeeCollector, {from: sysAdmin, gas: 400000, gasPrice: defaultGasPrice});
var transferOwnership2_2Output =gateWithFee.mintFeeCollector();

while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(transferOwnership2_1Tx, transferOwnership2Message + " - gateWithFee.setMintFeeCollector(sysAdmin)");
printTxData("transferOwnership2_2Tx", transferOwnership2_2Tx);
printTxData("transferOwnership2_1Output", transferOwnership2_1Output);

failIfTxStatusError(transferOwnership2_2Tx, transferOwnership2Output + " - gateWithFee.setMintFeeCollector(sysAdmin)");
printTxData("transferOwnership2_2Tx", transferOwnership2_2Tx);
printTxData("transferOwnership2_2Output", transferOwnership2_2Output);

// printGateRolesContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var mintTokenMessage = "Mint with dynamic fee";
var tokenNumber = "10000";
var tokenFee = "25";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + mintTokenMessage + " ----------");
var mintTokenWithFee_1Tx = gateWithFee.mintWithFee(account8,tokenNumber,tokenFee,{from: moneyOperator, gas: 400000, gasPrice: defaultGasPrice});
failIfTxStatusError(mintTokenWithFee_1Tx, mintTokenMessage + " - gateWithFee.mintWithFee(account8,tokenNumber,tokenFee)");
printTxData("mintTokenWithFee_1Tx", mintTokenWithFee_1Tx);
// fiatToken.totalSupply();
while (txpool.status.pending > 0) {
}
printBalances();
console.log("RESULT: ");

// -----------------------------------------------------------------------------
// User GateRoles
// -----------------------------------------------------------------------------
// - Initial deployer can add Sysadmin addresses. false, only sysadmin
// gateRoles.hasUserRole(account9,"1");  -> false
// gateRoles.setUserRole(account9,"1",true,{from: deployer, gas: 400000, gasPrice: defaultGasPrice});
// gateRoles.hasUserRole(account9,"1");  -> false
// gateRoles.setUserRole(account9,"1",true,{from: sysAdmin, gas: 400000, gasPrice: defaultGasPrice});
// gateRoles.hasUserRole(account9,"1");  -> true

// - Initial deployer can remove Sysadmin addresses. false, only sysadmin
// gateRoles.hasUserRole(sysAdmin,"1"); -> true
// gateRoles.hasUserRole(deployer,"1"); -> false
// gateRoles.setUserRole(sysAdmin,"1",false,{from: deployer, gas: 400000, gasPrice: defaultGasPrice});
// gateRoles.hasUserRole(sysAdmin,"1"); -> true  ( didnt work)

// gateRoles.setUserRole(deployer,"1",true,{from: sysAdmin, gas: 400000, gasPrice: defaultGasPrice});
// gateRoles.hasUserRole(deployer,"1"); -> true

// gateRoles.setUserRole(sysAdmin,"1",false,{from: deployer, gas: 400000, gasPrice: defaultGasPrice});
// gateRoles.hasUserRole(sysAdmin,"1"); -> true ( didnt work)
// gateRoles.setUserRole(deployer,"1",false,{from: sysAdmin, gas: 400000, gasPrice: defaultGasPrice});
// gateRoles.hasUserRole(deployer,"1"); -> false

// missing
gateRoles.setRoleCapability(SYSTEM_ADMIN_ROLE, web3.sha3("setUserRole(address,uint8,bool)").substring(0, 10), true, {from: deployer, gas: 400000, gasPrice: defaultGasPrice});

,web3.sha3("setUserRole(address,uint8,bool)").substring(0, 10));



> limitSetting.getBurnDailyLimit("0xa88a05d2b88283ce84c8325760b72a64591279a2", {from: deployer, gas: 400000, gasPrice: defaultGasPrice});
"0x02086c363a84ceba363a77ad299a59000f58664859ec9d3c808a67aa9abee38b"  -> Should be 0?

EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
