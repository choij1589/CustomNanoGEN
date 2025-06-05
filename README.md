# CustomNanoGEN
## Quick Start
To follow default configuration for Run3 NanoAODv12, CMSSW\_13\_0\_13 release is required.

```bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
scram p CMSSW_13_0_13
cd CMSSW_13_0_13/src
cmsenv
```

Get the code snippet from CustomNanoGEN
```bash
cd $CMSSW_BASE/src
git cms-init
git cms-merge-topic choij1589:from-CMSSW_13_0_13 # To get autodetect scripts
mkdir -p Configuration
git clone git@github.com:choij1589/CustomNanoGEN.git Configuration/CustomNanoGEN
scram b clean; scram b -j 4
```

## How to make a config file
In CMS, we use **fragment** to define the path to get the input gridpacks, and configure how to parse the output LHE files to Pythia8/Herwig7 to run parton shower and hadronization.
Here is an example of generating a config file to run GEN step for DY+3j CUDA gridpacks.
```bash
cd $CMSSW_BASE/src/Configuration/CustomNanoGEN
./scripts/runLocalCmsDriverGen.sh python/Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_AUTODETECT_LHE_pythia8_cff.py 10000 8
```

This will generate a config file in `configs/Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_AUTODETECT_LHE_pythia8_cfg.py`.
To initiate the GEN step using this config file, run the following command:
```bash
cd $CMSSW_BASE/src/Configuration/CustomNanoGEN
mkdir -p test && cd test
cp ../configs/Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_AUTODETECT_LHE_pythia8_cfg.py .
cmsRun Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_AUTODETECT_LHE_pythia8_cfg.py
```

## Quick Reference: CMSSW GEN with Auto-Detection

### Hardware Auto-Detection

| Hardware | Backend | Performance | Auto-Selected When |
|----------|---------|-------------|-------------------|
| NVIDIA GPU | `_CUDA_` | Highest | `nvidia-smi` works |
| AVX-512 CPU | `_CPP512Z_` | High | `avx512` in `/proc/cpuinfo` |
| AVX2 CPU | `_CPPAVX2_` | Medium | `avx2` in `/proc/cpuinfo` |
| Basic CPU | `_UPSTREAM_` | Basic | Fallback |

Here, we assume the PSet has landed in A100 GPU machine if it triggered nvidia-smi command.

### Fetching gridpacks
I have put example gridpacks(DY+3j) in my afs area:
```bash
/afs/cern.ch/work/c/choij/public/MG4GPU/gridpacks
```
You can download them manually and set a path in your `externalLHEProducer` (no `file:` prefix) and use `scriptName` as `GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs_autodetect.sh`. 
If you want to put the file in your EOS area and use xrootd, then you have to change your `scriptName` to `GeneratorInterface/LHEInterface/data/run_generic_tarball_xrootd_autodetect.sh`. Check `configs/Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_AUTODETECT_LHE_pythia8_cfg.py` for more concrete example.


### Key Configuration

```python
externalLHEProducer = cms.EDProducer('ExternalLHEProducer',
    args = cms.vstring(
        'root://path/to/DY3j_LO_5f_AUTODETECT_gridpack.tar.xz',  # Use _AUTODETECT_
        '5000'  # maxevt parameter
    ),
    numberOfParameters = cms.uint32(2),  # Updated for new maxevt param
    scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_xrootd_autodetect.sh'),
    # ... other settings
)
```

### Threading Control

```python
process.options = cms.untracked.PSet(
    numberOfThreads = cms.untracked.uint32(4),  # Controls nproc for runcmsgrid.sh
)
```

### Quick Debug

```bash
# Test hardware detection
bash GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs_autodetect.sh \
    "test_AUTODETECT_path.tar.xz" 100 1234 1 500 2>&1 | head -10

# Check your hardware
nvidia-smi  # CUDA check
grep 'flags' /proc/cpuinfo | grep -E 'avx|avx2|avx512'  # CPU check
```

### Common Parameters

| Parameter | Old Value | New Value | Notes |
|-----------|-----------|-----------|-------|
| `args` | `['gridpack.tar.xz']` | `['gridpack.tar.xz', '5000']` | Added maxevt |
| `numberOfParameters` | `1` | `2` | Updated count |
| `runcmsgrid.sh` args | `$nevt $rnum $ncpu` | `$nevt $rnum $nproc $maxevt` | New interface |

### Migration from Old Configs

1. **Add maxevt parameter**: Add second element to `args` vector
2. **Update numberOfParameters**: Change from `1` to `2`
3. **Use AUTODETECT**: Replace backend name with `_AUTODETECT_` in gridpack path
4. **Check threading**: Ensure `numberOfThreads` is set appropriately
