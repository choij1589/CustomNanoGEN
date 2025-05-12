#!/bin/bash
fragment=${1/python\//}
nevt=$2
SEED=$(($(date +%s) % 100 + 1))

cmsDriver.py Configuration/CustomNanoGEN/$fragment \
 --python_filename configs/${fragment/cff/cfg} \
 --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring \
 --datatier GEN --fileout file:GEN.root --mc \
 --conditions auto:mc --step LHE,GEN -n $nevt --no_exec || exit $?;
