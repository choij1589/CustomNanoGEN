#!/bin/bash
set -euo pipefail

PROCESS_LIST=("DY012j" "DY3j")
BACKEND_LIST=("UPSTREAM" "FORTRAN" "CPPNONE" "CPPAVX2" "CUDA")

for proc in "${PROCESS_LIST[@]}"; do
  for backend in "${BACKEND_LIST[@]}"; do
    echo "$proc $backend"
  done
done | xargs -n2 -P8 bash -c '
  # Using "_" as a dummy $0; $1 is process, $2 is backend
  proc="$1"
  backend="$2"
  workdir="cmsRun/${proc}_${backend}"
  echo "Starting: $proc with $backend in $workdir"
  mkdir -p "$workdir"
  cd "$workdir" || { echo "Failed to cd into $workdir"; exit 1; }
  # Copy the config file(s) matching the pattern. Adjust the glob as needed.
  cp ../../configs/Hadronizer_TuneCP5_13p6TeV_${proc}_MLM_${backend}_5f_*_LHE_pythia8_cfg.py .
  # Run the cms job and append output to log.txt
  cmsRun Hadronizer_*.py >> log.txt 2>&1
  echo "Finished: $proc with $backend"
' _



