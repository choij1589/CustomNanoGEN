# Quick Reference: CMSSW GEN with Auto-Detection

## Quick Start

```bash
# 1. Setup environment
cd /path/to/CMSSW_13_0_13/src && cmsenv

# 2. Create auto-detecting config
cmsDriver.py Configuration/CustomNanoGEN/Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_AUTODETECT_LHE_pythia8_cff.py \
    --step LHE,GEN --datatier GEN --fileout DY3j_GEN.root -n 1000 --no_exec

# 3. Run
cmsRun Hadronizer_TuneCP5_13p6TeV_DY3j_LO_5f_AUTODETECT_LHE_pythia8_cfg.py
```

## Hardware Auto-Detection

| Hardware | Backend | Performance | Auto-Selected When |
|----------|---------|-------------|-------------------|
| NVIDIA GPU | `_CUDA_` | Highest | `nvidia-smi` works |
| AVX-512 CPU | `_CPP512Z_` | High | `avx512` in `/proc/cpuinfo` |
| AVX2 CPU | `_CPPAVX2_` | Medium | `avx2` in `/proc/cpuinfo` |
| Basic CPU | `_LEGACY_` | Basic | Fallback |

## Key Configuration

```python
externalLHEProducer = cms.EDProducer('ExternalLHEProducer',
    args = cms.vstring(
        'root://path/to/DY3j_LO_5f_AUTODETECT_gridpack.tar.xz',  # Use _AUTODETECT_
        '5000'  # maxevt parameter
    ),
    numberOfParameters = cms.uint32(2),  # Updated for new maxevt param
    # ... other settings
)
```

## Threading Control

```python
process.options = cms.untracked.PSet(
    numberOfThreads = cms.untracked.uint32(4),  # Controls nproc for runcmsgrid.sh
)
```

## Quick Debug

```bash
# Test hardware detection
bash GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh \
    "test_AUTODETECT_path.tar.xz" 100 1234 1 500 2>&1 | head -10

# Check your hardware
nvidia-smi  # CUDA check
grep 'flags' /proc/cpuinfo | grep -E 'avx|avx2|avx512'  # CPU check
```

## Common Parameters

| Parameter | Old Value | New Value | Notes |
|-----------|-----------|-----------|-------|
| `args` | `['gridpack.tar.xz']` | `['gridpack.tar.xz', '5000']` | Added maxevt |
| `numberOfParameters` | `1` | `2` | Updated count |
| `runcmsgrid.sh` args | `$nevt $rnum $ncpu` | `$nevt $rnum $nproc $maxevt` | New interface |

## Migration from Old Configs

1. **Add maxevt parameter**: Add second element to `args` vector
2. **Update numberOfParameters**: Change from `1` to `2`
3. **Use AUTODETECT**: Replace backend name with `_AUTODETECT_` in gridpack path
4. **Check threading**: Ensure `numberOfThreads` is set appropriately

## Backend Performance Tips

- **CUDA**: Use `numberOfThreads = 1-2`, larger `maxevt` values
- **CPU vectorized**: Use `numberOfThreads = 4-8`, moderate `maxevt`
- **Legacy**: Use `numberOfThreads = 2-4`, smaller `maxevt` values 