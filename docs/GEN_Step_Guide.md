# CMSSW Generator Step (GEN) Guide with Auto-Detection

This guide covers running the Generator (GEN) step in CMSSW with the new automatic hardware detection and enhanced parameter handling features.

## Table of Contents
- [New Features](#new-features)
- [Hardware Auto-Detection](#hardware-auto-detection)
- [Usage Examples](#usage-examples)
- [Configuration Files](#configuration-files)
- [Parameter Reference](#parameter-reference)

## Required Dependencies

Ensure these are available in your environment:
- **CMSSW 13.0.13** or compatible version
- **XRootD** for gridpack access via `root://` protocol
- **NVIDIA drivers** (optional, for CUDA auto-detection)

## New Features

### **Automatic Hardware Detection**
- **CUDA GPU Detection**: Automatically detects NVIDIA GPUs and uses CUDA backend
- **CPU Vectorization Detection**: Detects AVX-512, AVX2 support for optimal CPU backends
- **Fallback Support**: Gracefully falls back to LEGACY backend if no advanced features are available

### **Enhanced Parameter Handling**
- **New `maxevt` Parameter**: Control maximum events per job for better resource management
- **Updated `runcmsgrid.sh` Interface**: Now supports `./runcmsgrid.sh $nevt $rnum $nproc $maxevt`
- **Backward Compatibility**: Maintains compatibility with existing configurations

## Hardware Auto-Detection

### Detection Priority (Highest to Lowest Performance)

1. **CUDA** (`_CUDA_`) - GPU acceleration
   - Requires: NVIDIA GPU + nvidia-smi available
   - Best for: GPU-accelerated matrix element calculations
   - Restriction: Not GPU-memory safe, have to pre-configure nThread option. Might not perform well on Consumer GPUs(e.g. RTX series / P4..)

2. **CPP512Z** (`_CPP512Z_`) - AVX-512 vectorization
   - Requires: AVX-512 CPU support
   - Best for: Latest Intel/AMD CPUs with AVX-512, 28% of the LCG machine supports

3. **CPPAVX2** (`_CPPAVX2_`) - AVX2 vectorization
   - Requires: AVX2 CPU support
   - Best for: Modern Intel/AMD CPUs (2013+), all of the LHC machine supports

4. **UPSTREAM** (`_UPSTREAM_`) - Fallback implementation
   - Requires: No special hardware
   - Best for: Older systems or when vectorization is unavailable

### Auto-Detection Process

When a gridpack path contains `_AUTODETECT_`, the system:

1. **Checks for CUDA**: Uses `nvidia-smi` to detect GPUs
2. **Checks CPU flags**: Reads `/proc/cpuinfo` for vectorization support
3. **Replaces path**: Automatically substitutes `_AUTODETECT_` with optimal backend

## Usage Examples

### Example 1: Auto-Detecting Configuration

```python
# Configuration/CustomNanoGEN/python/Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_AUTODETECT_LHE_pythia8_cff.py

import FWCore.ParameterSet.Config as cms

externalLHEProducer = cms.EDProducer('ExternalLHEProducer',
    args = cms.vstring(
        'root://eosuser.cern.ch//eos/user/c/choij/public/MG4GPU/gridpacks/validation/DY3j/DY3j_LO_5f_AUTODETECT_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz',
        '5000'  # maxevt - maximum events per job
    ),
    nEvents = cms.untracked.uint32(5000),
    numberOfParameters = cms.uint32(2),
    outputFile = cms.string('cmsgrid_final.lhe'),
    scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_xrootd.sh'),
    generateConcurrently = cms.untracked.bool(False),
)
```

### Example 2: Running the GEN Step

```bash
# Create configuration
cmsDriver.py Configuration/CustomNanoGEN/Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_AUTODETECT_LHE_pythia8_cff.py \
    --python_filename DY3j_AUTODETECT_GEN_cfg.py \
    --eventcontent RAWSIM \
    --datatier GEN \
    --fileout file:DY3j_GEN.root \
    --conditions auto:mc \
    --step LHE,GEN \
    --geometry DB:Extended \
    --era Run3 \
    --no_exec \
    --mc \
    -n 10000 \
    -nThreads 8

# Run the configuration
cmsRun DY3j_AUTODETECT_GEN_cfg.py
```

### Example 3: Manual Backend Selection

If you want to force a specific backend instead of auto-detection:

```python
# Force CUDA backend
args = cms.vstring(
    'root://eosuser.cern.ch//eos/user/c/choij/public/MG4GPU/gridpacks/validation/DY3j/DY3j_LO_5f_CUDA_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz',
    '5000'
),

# Force CPPAVX2 backend
args = cms.vstring(
    'root://eosuser.cern.ch//eos/user/c/choij/public/MG4GPU/gridpacks/validation/DY3j/DY3j_LO_5f_CPPAVX2_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz',
    '5000'
),
```

## Configuration Files

### Key Configuration Files

1. **Hadronizer Configuration**
   - `Configuration/CustomNanoGEN/python/Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_AUTODETECT_LHE_pythia8_cff.py`
   - Contains auto-detection setup

2. **Script Files**
   - `GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh` - Main execution script with auto-detection
   - `GeneratorInterface/LHEInterface/data/run_generic_tarball_xrootd.sh` - XRootD wrapper script

## Parameter Reference

### ExternalLHEProducer Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `args` | `vstring` | Gridpack path and additional arguments | `['root://...', '5000']` |
| `nEvents` | `uint32` | Total number of events to generate | `5000` |
| `numberOfParameters` | `uint32` | Number of arguments in `args` | `2` |
| `outputFile` | `string` | Output LHE file name | `'cmsgrid_final.lhe'` |
| `scriptName` | `FileInPath` | Script to execute | `'GeneratorInterface/LHEInterface/data/run_generic_tarball_xrootd.sh'` |
| `generateConcurrently` | `bool` | Enable concurrent generation | `False` |

### Script Arguments (Passed to `runcmsgrid.sh`)

| Position | Argument | Description | Source |
|----------|----------|-------------|---------|
| 1 | `nevt` | Number of events | Automatic from `nEvents` |
| 2 | `rnum` | Random seed | Automatic from RandomNumberGenerator |
| 3 | `nproc` | Number of threads | Automatic from `process.options.numberOfThreads` |
| 4 | `maxevt` | Maximum events per job | From `args[1]` |

### CMSSW Process Options

```python
process.options = cms.untracked.PSet(
    numberOfThreads = cms.untracked.uint32(4),  # Controls nproc parameter
    numberOfStreams = cms.untracked.uint32(0),
    # ... other options
)
```

**Last Updated**: December 2024  
**CMSSW Version**: 13.0.13  
