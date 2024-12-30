#!/bin/bash
fragment=${1/python\//}

cmsDriver.py Configuration/CustomNanoGEN/python/$fragment --no_exec -n 30 \
    --fileout file:NANOGEN.root --mc --eventcontent NANOAODGEN \
    --datatier NANOAOD --conditions auto:mc --step LHE,GEN,NANOGEN \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --python_filename configs/${fragment/cff/cfg}
