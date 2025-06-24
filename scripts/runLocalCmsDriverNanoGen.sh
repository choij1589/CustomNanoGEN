#!/bin/bash
fragment=${1/python\//}
nevt=$2
nthreads=$3
SEED=$(($(date +%s) % 100 + 1))

cmsDriver.py Configuration/CustomNanoGEN/python/$fragment \
    --python_filename configs/${fragment/cff/cfg} \
    --eventcontent NANOAODGEN --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier NANOAOD --fileout file:NANOGEN.root --mc \
    --conditions auto:mc --step LHE,GEN,NANOGEN -n $nevt --nThreads $nthreads --no_exec || exit $?
