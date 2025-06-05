# CMSSW Generator Step (GEN) Guide with Auto-Detection

This guide covers running the Generator (GEN) step in CMSSW with the new automatic hardware detection and enhanced parameter handling features.

## Table of Contents
- [Environment Setup](#environment-setup)
- [New Features](#new-features)
- [Hardware Auto-Detection](#hardware-auto-detection)
- [Usage Examples](#usage-examples)
- [Configuration Files](#configuration-files)
- [Parameter Reference](#parameter-reference)
- [Troubleshooting](#troubleshooting)

## Environment Setup

### 1. CMSSW Environment

```bash
# Set up CMSSW environment
export SCRAM_ARCH=el9_amd64_gcc11
source /cvmfs/cms.cern.ch/cmsset_default.sh

# Navigate to your working area
cd /path/to/your/workspace/CMSSW_13_0_13/src
cmsenv

# Compile if needed
scram b -j8
```

### 2. Required Dependencies

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

### **Improved Logging**
- **Detailed Hardware Detection Messages**: Clear logging of what hardware is detected
- **Backend Selection Transparency**: Shows which backend was automatically selected
- **Enhanced Error Reporting**: Better debugging information

## Hardware Auto-Detection

### Detection Priority (Highest to Lowest Performance)

1. **CUDA** (`_CUDA_`) - GPU acceleration
   - Requires: NVIDIA GPU + nvidia-smi available
   - Best for: GPU-accelerated matrix element calculations

2. **CPP512Z** (`_CPP512Z_`) - AVX-512 vectorization
   - Requires: AVX-512 CPU support
   - Best for: Latest Intel/AMD CPUs with AVX-512

3. **CPPAVX2** (`_CPPAVX2_`) - AVX2 vectorization
   - Requires: AVX2 CPU support
   - Best for: Modern Intel/AMD CPUs (2013+)

4. **LEGACY** (`_LEGACY_`) - Fallback implementation
   - Requires: No special hardware
   - Best for: Older systems or when vectorization is unavailable

### Auto-Detection Process

When a gridpack path contains `_AUTODETECT_`, the system:

1. **Checks for CUDA**: Uses `nvidia-smi` to detect GPUs
2. **Checks CPU flags**: Reads `/proc/cpuinfo` for vectorization support
3. **Replaces path**: Automatically substitutes `_AUTODETECT_` with optimal backend
4. **Logs selection**: Reports which backend was chosen and why

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
    -n 1000

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

### Gridpack Naming Convention

Gridpacks should follow this naming pattern for auto-detection:
```
{Process}_AUTODETECT_{os}_{arch}_{compiler}_CMSSW_{version}_tarball.tar.xz
```

Example:
```
DY3j_LO_5f_AUTODETECT_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz
```

Available backends:
- `_AUTODETECT_` - Automatic detection
- `_CUDA_` - NVIDIA GPU acceleration
- `_CPP512Z_` - AVX-512 vectorization
- `_CPPAVX2_` - AVX2 vectorization
- `_LEGACY_` - Fallback implementation

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

## Troubleshooting

### Common Issues and Solutions

#### 1. Auto-Detection Not Working

**Symptoms**: Always falls back to LEGACY backend

**Solutions**:
- Check if gridpack path contains `_AUTODETECT_`
- Verify NVIDIA drivers for CUDA detection: `nvidia-smi`
- Check CPU flags: `grep 'flags' /proc/cpuinfo | grep -E 'avx|avx2|avx512'`

#### 2. Gridpack Not Found

**Symptoms**: `tar: Cannot connect to root` or similar errors

**Solutions**:
- Verify gridpack exists at the specified path
- Check XRootD connectivity: `xrdcp root://... test.tar.xz`
- Ensure correct backend is available (e.g., `_CUDA_` gridpack exists if CUDA is detected)

#### 3. Parameter Mismatch

**Symptoms**: `Problem with configuration: X script arguments given, expected Y`

**Solutions**:
- Ensure `numberOfParameters` matches the number of elements in `args`
- For auto-detection with `maxevt`: use `numberOfParameters = cms.uint32(2)`

#### 4. Threading Issues

**Symptoms**: Poor performance or resource conflicts

**Solutions**:
- Adjust `process.options.numberOfThreads` based on available cores
- For CUDA: typically use fewer threads (1-2) per GPU
- For CPU backends: use more threads (4-8) depending on cores

### Debugging Tips

#### Enable Verbose Logging

```python
process.MessageLogger = cms.Service("MessageLogger",
    destinations = cms.untracked.vstring('cout'),
    cout = cms.untracked.PSet(
        threshold = cms.untracked.string('DEBUG')
    )
)
```

#### Check Hardware Detection Manually

```bash
# Test the detection function
bash GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh \
    "test_AUTODETECT_path.tar.xz" 100 1234 1 500 2>&1 | head -20
```

#### Verify Gridpack Contents

```bash
# List available backends in your gridpack repository
xrdfs root://eosuser.cern.ch ls /eos/user/c/choij/public/MG4GPU/gridpacks/validation/DY3j/
```

### Performance Optimization

#### For CUDA Systems
- Use `numberOfThreads = 1-2`
- Enable `generateConcurrently = False` (single GPU)
- Set appropriate `maxevt` based on GPU memory

#### For CPU Systems
- Use `numberOfThreads = 4-8` (match CPU cores)
- Consider `generateConcurrently = True` for multiple processes
- Adjust `maxevt` for memory constraints

#### For Batch Systems
- Auto-detection works well with heterogeneous clusters
- Use `_AUTODETECT_` gridpacks for maximum portability
- Set conservative `maxevt` values for stability

## Advanced Usage

### Custom Hardware Detection

You can extend the detection logic in `run_generic_tarball_cvmfs.sh`:

```bash
# Add custom detection for specific architectures
if [[ $(uname -m) == "aarch64" ]]; then
    echo "%MSG-MG5 ARM64 detected, using custom backend"
    echo "${base_path//_AUTODETECT_/_ARM64_}"
    return
fi
```

### Environment Variables

Set these environment variables to influence behavior:

```bash
export CUDA_VISIBLE_DEVICES=0,1  # Limit CUDA devices
export OMP_NUM_THREADS=4         # Control OpenMP threads
```

### Integration with Workflow Management

For HTCondor/Slurm integration:

```bash
# In your job script
cd $CMSSW_BASE/src
cmsenv
cmsRun your_autodetect_cfg.py

# The auto-detection will adapt to the execution node's hardware
```

---

**Last Updated**: December 2024  
**CMSSW Version**: 13.0.13  
**Contact**: For issues, please check the troubleshooting section or consult CMSSW documentation. 