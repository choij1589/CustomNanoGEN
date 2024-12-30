#!/bin/bash
fragment=${1/python\//}

cmsDriver.py Configuration/CustomNanoGEN/python/$fragment \
    --fileout file:NANOGEN.root --mc --eventcontent NANOAODGEN \
    --datatier NANOAOD --conditions auto:mc --step LHE,GEN,NANOGEN \
    --python_filename configs/${fragment/cff/cfg} \ 
    --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed=999  -n 30 --no_exec
