from CRABClient.UserUtilities import config
config = config()

config.General.requestName = "TTToHcToWAToMuMu_MHc70_MA40"
config.General.workArea = "crab_projects"
config.General.transferOutputs = True
config.General.transferLogs = True

config.JobType.pluginName = 'PrivateMC'
config.JobType.psetName = '../../configs/Hadronizer_TuneCP5_13p6TeV_TTToHcToWAToMuMu_MHc70_MA40_MultiLepFilter_LHE_pythia8_cfg.py'
config.JobType.allowUndistributedCMSSW = True
config.JobType.numCores = 1

config.Data.outputPrimaryDataset = 'TTToHcToWAToMuMu_MHc70_MA40_NANOGEN'
config.Data.splitting = 'EventBased'
config.Data.unitsPerJob = 5000
NJOBS = 20  # This is not a configuration parameter, but an auxiliary variable that we use in the next line.
config.Data.totalUnits = config.Data.unitsPerJob * NJOBS
config.Data.outLFNDirBase = '/store/user/choij'
config.Data.publication = False
config.Data.outputDatasetTag = 'Run3Summer23wmLHEGEN'

config.Site.storageSite = 'T3_KR_KNU'
