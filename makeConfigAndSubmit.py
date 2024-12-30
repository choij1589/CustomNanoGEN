#!/usr/bin/env python3
import os, shutil
import subprocess
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--masspoint", required=True, type=str, help="signal mass point")
args = parser.parse_args()

FRAGMENT = f"Hadronizer_TuneCP5_13TeV_TTToHcToWAToMuMu_{args.masspoint}_MultiLepFilter_LHE_pythia8_cff.py"

# make python fragment
with open(f"templates/Hadronizer_TuneCP5_13TeV_TTToHcToWAToMuMu_MultiLepFilter_LHE_pythia8_cff.py", "r") as f:
    fragment = f.read()

with open(f"python/{FRAGMENT}", "w") as f:
    f.write(fragment.replace("[MASSPOINT]", args.masspoint))

# run cmsDriver.py command
command = f"./scripts/runCmsDriverNanoGen.sh {FRAGMENT}"
result = subprocess.run(command, shell=True, capture_output=Ture, text=True)

print(result.stdout)
