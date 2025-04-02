#!/bin/bash
# example name of gridpack: DY1j_LO_5f_CPPNONE_el9_amd64_gcc12_CMSSW_14_0_9_tarball.tar.xz
PROCESS=$1
BACKEND=$2

if [ -z "$PROCESS" ] || [ -z "$BACKEND" ]; then
    echo "Usage: $0 <process> <backend>"
    exit 1
fi
GRIDPACK="${PROCESS}_${BACKEND}_el9_amd64_gcc12_CMSSW_14_0_9_tarball.tar.xz"

# Extract number of external jets from the process name
if [[ "$PROCESS" =~ ([0-9]+)j ]]; then
    NJETMAX=${BASH_REMATCH[1]}
else
    NJETMAX=0
fi
echo "Gridpack: $GRIDPACK"
echo "Detected NJetMax: $NJETMAX for process $PROCESS"

# find template
TEMPLATE=""
if [[ "$PROCESS" == "DY"* ]] || [[ "$PROCESS" == "W"* ]]; then
    TEMPLATE="templates/Hadronizer_TuneCP5_13p6TeV_DrellYan_LHE_pythia8_cff.py"
elif [[ "$PROCESS" == "TT"* ]]; then
    TEMPLATE="templates/Hadronizer_TuneCP5_13p6TeV_TT_LHE_pythia8_cff.py"
else
    echo "Process $PROCESS not supported"
    exit 1
fi

# save the template in python/ directory and replace GRIDPACK and NJETMAX
OUTPUT_FRAGMENT="python/Hadronizer_TuneCP5_13p6TeV_${PROCESS}_${BACKEND}_LHE_pythia8_cff.py"
# check if the output fragment already exists. Ask user to overwrite it.
if [ -f $OUTPUT_FRAGMENT ]; then
    echo "Output fragment $OUTPUT_FRAGMENT already exists"
    read -p "Do you want to overwrite it? (y/n): " overwrite
    if [ "$overwrite" != "y" ]; then
        echo "Exiting..."
        exit 1
    fi
fi

cp $TEMPLATE $OUTPUT_FRAGMENT
sed -i "s/\[GRIDPACK\]/$GRIDPACK/g" $OUTPUT_FRAGMENT
sed -i "s/\[NJETMAX\]/$NJETMAX/g" $OUTPUT_FRAGMENT

echo "Output fragment $OUTPUT_FRAGMENT created"
