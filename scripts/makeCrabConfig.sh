#!/bin/bash
PROCESS=$1
BACKEND=$2

# At this point, we have the config files.
CRAB_TEMPLATE="templates/crab_config.13p6TeV.py"

# Make crab config
cp $CRAB_TEMPLATE "crab/crab_config_${PROCESS}_${BACKEND}.py"
sed -i "s/\[REQUESTNAME\]/${PROCESS}_${BACKEND}/g" "crab/crab_config_${PROCESS}_${BACKEND}.py"
sed -i "s/\[CONFIG\]/Hadronizer_TuneCP5_13p6TeV_${PROCESS}_${BACKEND}_LHE_pythia8_cfg.py/g" "crab/crab_config_${PROCESS}_${BACKEND}.py"

echo "Crab config created for ${PROCESS}_${BACKEND}"




