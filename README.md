# CustomNanoGEN
## Installation
To follow default configuration for Run3 NanoAODv12, CMSSW_13_0_13 release is required.

```bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
scram p CMSSW_13_0_13
cd CMSSW_13_0_13/src
cmsenv
```

Get the code snippet from CustomNanoGEN
```bash
cd $CMSSW_BASE/src
mkdir -p Configuration
git clone git@github.com:choij1589/CustomNanoGEN.git Configuration/CustomNanoGEN
scram b clean; scram b -j 4
```

## How to make a config file
In CMS, we use **fragment** to define the path to get the input gridpacks, and configure how to parse the output LHE files to Pythia8/Herwig7 to run parton shower and hadronization.
Here is an example of generating a config file to run GEN step for DY+3j CUDA gridpacks.
```bash
cd $CMSSW_BASE/src/Configuration/CustomNanoGEN
./scripts/runLocalCmsDriverGen.sh python/Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_CUDA_LHE_pythia8_cff.py 5000
```

This will generate a config file in `configs/Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_CUDA_LHE_pythia8_cfg.py`.
To initiate the GEN step using this config file, run the following command:
```bash
cd $CMSSW_BASE/src/Configuration/CustomNanoGEN
mkdir -p test && cd test
cp ../configs/Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_CUDA_LHE_pythia8_cfg.py .
cmsRun Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_CUDA_LHE_pythia8_cfg.py
```

## To do
- [ ] Running multiple madevents within single gridpack is enabled in MG362, but ExternalLHEProducer lack of this feature.
- [ ] Method to use the GPU gridpacks optimally (Can it be automatically decided?)
- [ ] Comparing the LHE file production and Pythia shower speed
- [ ] Parallelizing the systematic computation
- [ ] Test run in CMS-connect