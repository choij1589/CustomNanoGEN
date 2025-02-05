#!/bin/bash
fragment=${1/python\//}
nevt=$2
SEED=$(($(date +%s) % 100 + 1))

# Run3
cmsDriver.py Configuration/CustomNanoGEN/python/$fragment --python_filename configs/${fragment/cff/cfg} \
    --eventcontent NANOAODGEN --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier NANOAOD --fileout file:NANOGEN.root --conditions 130X_mcRun3_2023_realistic_v14 \
    --beamspot Realistic25ns13p6TeVEarly2023Collision \
    --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${SEED})" \
                         process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(243)" \
    --step LHE,GEN,NANOGEN --geometry DB:Extended --era Run3_2023 \
    --no_exec --mc -n $nevt || exit $?;
