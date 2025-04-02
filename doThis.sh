#!/bin/bash
PROCESS_LIST=("DY0j_LO_5f" "DY1j_LO_5f" "DY2j_LO_5f" "DY3j_LO_5f"
              "W0j_LO_5f" "W1j_LO_5f" "W2j_LO_5f" "W3j_LO_5f")
BACKEND_LIST=("UPSTREAM" "LEGACY" "FORTRAN" "CPPNONE" "CPPAVX2")

for proc in "${PROCESS_LIST[@]}"; do
  for backend in "${BACKEND_LIST[@]}"; do
    ./scripts/makeFragments.sh $proc $backend
  done
done

scram b clean; scram b -j 8

for proc in "${PROCESS_LIST[@]}"; do
  for backend in "${BACKEND_LIST[@]}"; do
    ./scripts/runCmsDriverNanoGen.sh python/Hadronizer_TuneCP5_13p6TeV_${proc}_${backend}_LHE_pythia8_cff.py 5000
  done
done

for proc in "${PROCESS_LIST[@]}"; do
  for backend in "${BACKEND_LIST[@]}"; do
    ./scripts/makeCrabConfig.sh $proc $backend
  done
done
