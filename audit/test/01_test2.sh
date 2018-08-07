#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`

SETTINGS_FILE="settings.txt"
source $SETTINGS_FILE

CURRENTTIME=`date +%s`
CURRENTTIMES=`perl -le "print scalar localtime $CURRENTTIME"`
START_DATE=`echo "$CURRENTTIME+45" | bc`
START_DATE_S=`perl -le "print scalar localtime $START_DATE"`
END_DATE=`echo "$CURRENTTIME+60*2" | bc`
END_DATE_S=`perl -le "print scalar localtime $END_DATE"`

printf "MODE                               = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT                    = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD                           = '$PASSWORD'\n" | tee -a $TEST1OUTPUT
printf "SOURCEDIR                          = '$SOURCEDIR'\n" | tee -a $TEST1OUTPUT
printf "TESTDIR                            = '$TESTDIR'\n" | tee -a $TEST1OUTPUT

printf "ADDRESSSTATUSSOL                   = '$ADDRESSSTATUSSOL'\n" | tee -a $TEST1OUTPUT
printf "FIATTOKENSOL                       = '$FIATTOKENSOL'\n" | tee -a $TEST1OUTPUT
printf "GATESOL                            = '$GATESOL'\n" | tee -a $TEST1OUTPUT
printf "GATEROLESSOL                       = '$GATEROLESSOL'\n" | tee -a $TEST1OUTPUT
printf "GATEWITHFEESOL                     = '$GATEWITHFEESOL'\n" | tee -a $TEST1OUTPUT
printf "KYCSOL                             = '$KYCSOL'\n" | tee -a $TEST1OUTPUT
printf "LIMITCONTROLLERSOL                 = '$LIMITCONTROLLERSOL'\n" | tee -a $TEST1OUTPUT
printf "LIMITSETTINGSOL                    = '$LIMITSETTINGSOL'\n" | tee -a $TEST1OUTPUT
printf "MEMBERSHIPSOL                      = '$MEMBERSHIPSOL'\n" | tee -a $TEST1OUTPUT
printf "MULTISIGSOL                        = '$MULTISIGSOL'\n" | tee -a $TEST1OUTPUT
printf "TOKENAUTHSOL                       = '$TOKENAUTHSOL'\n" | tee -a $TEST1OUTPUT
printf "TOKENRULESSOL                      = '$TOKENRULESSOL'\n" | tee -a $TEST1OUTPUT
printf "TRANSFERFEECONTROLLERSOL           = '$TRANSFERFEECONTROLLERSOL'\n" | tee -a $TEST1OUTPUT
printf "TRANSFERFEECONTROLLERINTERFACESOL  = '$TRANSFERFEECONTROLLERINTERFACESOL'\n" | tee -a $TEST1OUTPUT
printf "DAPPSYSSOL                         = '$DAPPSYSSOL'\n" | tee -a $TEST1OUTPUT
printf "SOLOVAULTSOL                       = '$SOLOVAULTSOL'\n" | tee -a $TEST1OUTPUT

printf "ADDRESSSTATUSJS                    = '$ADDRESSSTATUSJS'\n" | tee -a $TEST1OUTPUT
printf "FIATTOKENJS                        = '$FIATTOKENJS'\n" | tee -a $TEST1OUTPUT
printf "GATEJS                             = '$GATEJS'\n" | tee -a $TEST1OUTPUT
printf "GATEROLESJS                        = '$GATEROLESJS'\n" | tee -a $TEST1OUTPUT
printf "GATEWITHFEEJS                      = '$GATEWITHFEEJS'\n" | tee -a $TEST1OUTPUT
printf "KYCJS                              = '$KYCJS'\n" | tee -a $TEST1OUTPUT
printf "LIMITCONTROLLERJS                  = '$LIMITCONTROLLERJS'\n" | tee -a $TEST1OUTPUT
printf "LIMITSETTINGJS                     = '$LIMITSETTINGJS'\n" | tee -a $TEST1OUTPUT
printf "MEMBERSHIPJS                       = '$MEMBERSHIPJS'\n" | tee -a $TEST1OUTPUT
printf "MULTISIGJS                         = '$MULTISIGJS'\n" | tee -a $TEST1OUTPUT
printf "TOKENAUTHJS                        = '$TOKENAUTHJS'\n" | tee -a $TEST1OUTPUT
printf "TOKENRULESJS                       = '$TOKENRULESJS'\n" | tee -a $TEST1OUTPUT
printf "TRANSFERFEECONTROLLERJS            = '$TRANSFERFEECONTROLLERJS'\n" | tee -a $TEST1OUTPUT
printf "TRANSFERFEECONTROLLERINTERFACEJS   = '$TRANSFERFEECONTROLLERINTERFACEJS'\n" | tee -a $TEST1OUTPUT
printf "DAPPSYSJS                          = '$DAPPSYSJS'\n" | tee -a $TEST1OUTPUT
printf "SOLOVAULTJS                        = '$SOLOVAULTJS'\n" | tee -a $TEST1OUTPUT

#printf "TESTCONTRACT1SOL                   = '$TESTCONTRACT1SOL'\n" | tee -a $TEST1OUTPUT
#printf "TESTCONTRACT1JS                    = '$TESTCONTRACT1JS'\n" | tee -a $TEST1OUTPUT
printf "DEPLOYMENTDATA                     = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS                          = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT                        = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS                       = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME                        = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "START_DATE                         = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "END_DATE                           = '$END_DATE' '$END_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
# Make copy of SOL file ---
#cp $SOURCEDIR/* .
rsync -rp --progress $SOURCEDIR/* .  --exclude=Multisig.sol --exclude=test/

# Copy modified contracts if any files exist
find ./modifiedContracts -type f -name \* -exec cp {} . \;

# --- Modify parameters ---
# `perl -pi -e "s/START_DATE \= 1525132800.*$/START_DATE \= $START_DATE; \/\/ $START_DATE_S/" $CROWDSALESOL`
# `perl -pi -e "s/endDate \= 1527811200;.*$/endDate \= $END_DATE; \/\/ $END_DATE_S/" $CROWDSALESOL`
#`perl -pi -e "s/contracts\///" *.sol`
# `perl -pi -e "s/contracts\///" _examples/*.sol`


#DIFFS1=`diff -r -x '*.js' -x '*.json' -x '*.txt' -x 'testchain' -x '*.md' $SOURCEDIR .`
#echo "--- Differences $SOURCEDIR/$REQUESTFACTORYSOL $REQUESTFACTORYSOL ---" | tee -a $TEST1OUTPUT
#echo "$DIFFS1" | tee -a $TEST1OUTPUT

solc --version | tee -a $TEST1OUTPUT

#echo "var AddressStatusOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $ADDRESSSTATUSSOL`;" > $ADDRESSSTATUSJS
echo "var FiatTokenOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $FIATTOKENSOL`;" > $FIATTOKENJS
#echo "var GateOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $GATESOL`;" > $GATEJS
echo "var GateRolesOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $GATEROLESSOL`;" > $GATEROLESJS
echo "var GateWithFeeOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $GATEWITHFEESOL`;" > $GATEWITHFEEJS
echo "var KycOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $KYCSOL`;" > $KYCJS
echo "var LimitControllerOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $LIMITCONTROLLERSOL`;" > $LIMITCONTROLLERJS
echo "var LimitSettingOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $LIMITSETTINGSOL`;" > $LIMITSETTINGJS
#echo "var MembershipOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $MEMBERSHIPSOL`;" > $MEMBERSHIPJS
#echo "var MultisigOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $MULTISIGSOL`;" > $MULTISIGJS
#echo "var TokenAuthOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $TOKENAUTHSOL`;" > $TOKENAUTHJS
#echo "var TokenRulesOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $TOKENRULESSOL`;" > $TOKENRULESJS
echo "var TransferFeeControllerOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $TRANSFERFEECONTROLLERSOL`;" > $TRANSFERFEECONTROLLERJS
#echo "var TransferFeeControllerInterfaceOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $TRANSFERFEECONTROLLERINTERFACESOL`;" > $TRANSFERFEECONTROLLERINTERFACEJS
echo "var dappsysOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $DAPPSYSSOL`;" > $DAPPSYSJS
#echo "var solovaultOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $SOLOVAULTSOL`;" > $SOLOVAULTJS



#echo "var testOutput=`solc --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $TESTDIR/$TESTCONTRACT1SOL`;" > $TESTCONTRACT1JS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
// loadScript("$ADDRESSSTATUSJS");
loadScript("$FIATTOKENJS");
// loadScript("$GATEJS");
loadScript("$GATEROLESJS");
loadScript("$GATEWITHFEEJS");
loadScript("$KYCJS");
loadScript("$LIMITCONTROLLERJS");
loadScript("$LIMITSETTINGJS");
// loadScript("$MEMBERSHIPJS");
// loadScript("$MULTISIGJS");
// loadScript("$TOKENAUTHJS");
// loadScript("$TOKENRULESJS");
loadScript("$TRANSFERFEECONTROLLERJS");
// loadScript("$TRANSFERFEECONTROLLERINTERFACEJS");
loadScript("$DAPPSYSJS");
// loadScript("$SOLOVAULTJS");

// loadScript("$TESTCONTRACT1JS");
loadScript("functions.js");

// var AddressStatusAbi = JSON.parse(AddressStatusOutput.contracts["$ADDRESSSTATUSSOL:AddressStatus"].abi);
// var AddressStatusBin = "0x" + AddressStatusOutput.contracts["$ADDRESSSTATUSSOL:AddressStatus"].bin;
var FiatTokenAbi = JSON.parse(FiatTokenOutput.contracts["$FIATTOKENSOL:FiatToken"].abi);
var FiatTokenBin = "0x" + FiatTokenOutput.contracts["$FIATTOKENSOL:FiatToken"].bin;
// var GateAbi = JSON.parse(GateOutput.contracts["$GATESOL:Gate"].abi);
// var GateBin = "0x" + GateOutput.contracts["$GATESOL:Gate"].bin;
var GateRolesAbi = JSON.parse(GateRolesOutput.contracts["$GATEROLESSOL:GateRoles"].abi);
var GateRolesBin = "0x" + GateRolesOutput.contracts["$GATEROLESSOL:GateRoles"].bin;
var GateWithFeeAbi = JSON.parse(GateWithFeeOutput.contracts["$GATEWITHFEESOL:GateWithFee"].abi);
var GateWithFeeBin = "0x" + GateWithFeeOutput.contracts["$GATEWITHFEESOL:GateWithFee"].bin;
var AddressControlStatusAbi = JSON.parse(KycOutput.contracts["$KYCSOL:AddressControlStatus"].abi);
var AddressControlStatusBin = "0x" + KycOutput.contracts["$KYCSOL:AddressControlStatus"].bin;
var KycAmlStatusAbi = JSON.parse(KycOutput.contracts["$KYCSOL:KycAmlStatus"].abi);
var KycAmlStatusBin = "0x" + KycOutput.contracts["$KYCSOL:KycAmlStatus"].bin;
var NoKycAmlRuleAbi = JSON.parse(KycOutput.contracts["$KYCSOL:NoKycAmlRule"].abi);
var NoKycAmlRuleBin = "0x" + KycOutput.contracts["$KYCSOL:NoKycAmlRule"].bin;
var BoundaryKycAmlRuleAbi = JSON.parse(KycOutput.contracts["$KYCSOL:BoundaryKycAmlRule"].abi);
var BoundaryKycAmlRuleBin = "0x" + KycOutput.contracts["$KYCSOL:BoundaryKycAmlRule"].bin;
var FullKycAmlRuleAbi = JSON.parse(KycOutput.contracts["$KYCSOL:FullKycAmlRule"].abi);
var FullKycAmlRuleBin = "0x" + KycOutput.contracts["$KYCSOL:FullKycAmlRule"].bin;
var MembershipWithBoundaryKycAmlRuleAbi = JSON.parse(KycOutput.contracts["$KYCSOL:MembershipWithBoundaryKycAmlRule"].abi);
var MembershipWithBoundaryKycAmlRuleBin = "0x" + KycOutput.contracts["$KYCSOL:MembershipWithBoundaryKycAmlRule"].bin;
var LimitControllerAbi = JSON.parse(LimitControllerOutput.contracts["$LIMITCONTROLLERSOL:LimitController"].abi);
var LimitControllerBin = "0x" + LimitControllerOutput.contracts["$LIMITCONTROLLERSOL:LimitController"].bin;
var LimitSettingAbi = JSON.parse(LimitSettingOutput.contracts["$LIMITSETTINGSOL:LimitSetting"].abi);
var LimitSettingBin = "0x" + LimitSettingOutput.contracts["$LIMITSETTINGSOL:LimitSetting"].bin;
// var MembershipAbi = JSON.parse(MembershipOutput.contracts["$MEMBERSHIPSOL:MockOAXMembership"].abi);
// var MembershipBin = "0x" + MembershipOutput.contracts["$MEMBERSHIPSOL:MockOAXMembership"].bin;
var TransferFeeControllerAbi = JSON.parse(TransferFeeControllerOutput.contracts["$TRANSFERFEECONTROLLERSOL:TransferFeeController"].abi);
var TransferFeeControllerBin = "0x" + TransferFeeControllerOutput.contracts["$TRANSFERFEECONTROLLERSOL:TransferFeeController"].bin;
var DSGuardAbi = JSON.parse(dappsysOutput.contracts["$DAPPSYSSOL:DSGuard"].abi);
var DSGuardBin = "0x" + dappsysOutput.contracts["$DAPPSYSSOL:DSGuard"].bin;

// console.log("DATA: AddressStatusAbi=" + JSON.stringify(AddressStatusAbi));
// console.log("DATA: AddressStatusBin=" + JSON.stringify(AddressStatusBin));
console.log("DATA: FiatTokenAbi=" + JSON.stringify(FiatTokenAbi));
console.log("DATA: FiatTokenBin=" + JSON.stringify(FiatTokenBin));
// console.log("DATA: GateAbi=" + JSON.stringify(GateAbi));
// console.log("DATA: GateBin=" + JSON.stringify(GateBin));
console.log("DATA: GateRolesAbi=" + JSON.stringify(GateRolesAbi));
console.log("DATA: GateRolesBin=" + JSON.stringify(GateRolesBin));
console.log("DATA: GateWithFeeAbi=" + JSON.stringify(GateWithFeeAbi));
console.log("DATA: GateWithFeeBin=" + JSON.stringify(GateWithFeeBin));
console.log("DATA: KycAbi=" + JSON.stringify(KycAbi));
console.log("DATA: KycBin=" + JSON.stringify(KycBin));
console.log("DATA: LimitControllerAbi=" + JSON.stringify(LimitControllerAbi));
console.log("DATA: LimitControllerBin=" + JSON.stringify(LimitControllerBin));
console.log("DATA: LimitSettingAbi=" + JSON.stringify(LimitSettingAbi));
console.log("DATA: LimitSettingBin=" + JSON.stringify(LimitSettingBin));
// console.log("DATA: MembershipAbi=" + JSON.stringify(MembershipAbi));
// console.log("DATA: MembershipBin=" + JSON.stringify(MembershipBin));


unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");

// -----------------------------------------------------------------------------
var deployGateRolesMessage = "Deploy GateRoles & FiatToken";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployGateRolesMessage + " ----------");
var gateRolesContract = web3.eth.contract(GateRolesAbi);
var gateRolesTx = null;
var gateRolesAddress = null;
var gateRoles = gateRolesContract.new({from: contractOwnerAccount, data: GateRolesBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        gateRolesTx = contract.transactionHash;
      } else {
        gateRolesAddress = contract.address;
        addAccount(gateRolesAddress, "GateRoles");
        console.log("DATA: gateRolesAddress=\"" + gateRolesAddress + "\";");
    }}}
);
var fiatTokenContract = web3.eth.contract(FiatTokenAbi);
var fiatTokenTx = null;
var fiatTokenAddress = null;
var fiatToken = fiatTokenContract.new({from: contractOwnerAccount, data: FiatTokenBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        fiatTokenTx = contract.transactionHash;
      } else {
        fiatTokenAddress = contract.address;
        addAccount(fiatTokenAddress, "FiatToken");
        console.log("DATA: fiatTokenAddress=\"" + fiatTokenAddress + "\";");
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(gateRolesTx, deployGateRolesMessage + " - GateRoles");
failIfTxStatusError(fiatTokenTx, deployGateRolesMessage + " - FiatToken");
printTxData("gateRolesTx", gateRolesTx);
printTxData("fiatTokenTx", fiatTokenTx);
console.log("RESULT: ");

EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
