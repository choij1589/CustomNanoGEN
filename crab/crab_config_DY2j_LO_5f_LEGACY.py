from CRABClient.UserUtilities import config, getUsername

config = config()
### General configuration
config.General.workArea        = 'crab_projects'
config.General.requestName     = 'DY2j_LO_5f_LEGACY'
config.General.transferOutputs = True
config.General.transferLogs    = False

### JobType configuration
config.JobType.psetName        = '../configs/Hadronizer_TuneCP5_13p6TeV_DY2j_LO_5f_LEGACY_LHE_pythia8_cfg.py'
config.JobType.pluginName      = 'PrivateMC'
config.JobType.allowUndistributedCMSSW = False
config.JobType.numCores        = 1

### Data configuration
config.Data.outputPrimaryDataset = 'Validation'
config.Data.splitting          = 'EventBased'
config.Data.unitsPerJob        = 5000
NJOBS = 40
config.Data.totalUnits         = config.Data.unitsPerJob * NJOBS
config.Data.outLFNDirBase      = '/store/user/%s/CustomNanoGEN' % (getUsername())
config.Data.publication        = False
config.Data.outputDatasetTag   = 'Run3Summer23wmLHEGS'

### Site configuration
config.Site.storageSite       = 'T3_KR_KNU'
