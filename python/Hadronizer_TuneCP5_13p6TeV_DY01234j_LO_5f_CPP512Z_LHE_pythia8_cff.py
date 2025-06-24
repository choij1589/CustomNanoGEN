import FWCore.ParameterSet.Config as cms

externalLHEProducer = cms.EDProducer('ExternalLHEProducer',
    args = cms.vstring('root://eosuser.cern.ch//eos/user/c/choij/public/MG4GPU/gridpacks/validation/DY01234j/DY01234j_LO_5f_CPP512Z_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz',
                       '5000'),  # maxevt - maximum events per job
    nEvents = cms.untracked.uint32(5000),
    numberOfParameters = cms.uint32(2),
    outputFile = cms.string('cmsgrid_final.lhe'),
    scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_xrootd_autodetect.sh'),
    generateConcurrently = cms.untracked.bool(False),
)

from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunesRun3ECM13p6TeV.PythiaCP5Settings_cfi import *
from Configuration.Generator.PSweightsPythia.PythiaPSweightsSettings_cfi import *

generator = cms.EDFilter("Pythia8ConcurrentHadronizerFilter",
    PythiaParameters = cms.PSet(
        pythia8CommonSettingsBlock,
        pythia8CP5SettingsBlock,
        pythia8PSweightsSettingsBlock,
        processParameters = cms.vstring(
            'JetMatching:setMad = off',
            'JetMatching:scheme = 1',
            'JetMatching:merge = on',
            'JetMatching:jetAlgorithm = 2',
            'JetMatching:etaJetMax = 5.',
            'JetMatching:coneRadius = 1.',
            'JetMatching:slowJetPower = 1',
            'JetMatching:doShowerKt = off', 
            'JetMatching:qCut = 19.',
            'JetMatching:nQmatch = 5',
            'JetMatching:nJetMax = 4',
            'TimeShower:mMaxGamma = 4.0'
        ),
        parameterSets = cms.vstring(
            'pythia8CommonSettings',
            'pythia8CP5Settings',
            'processParameters',
            'pythia8PSweightsSettings'
        )
    ),
    comEnergy = cms.double(13600),
    maxEventsToPrint = cms.untracked.int32(1),
    pythiaHepMCVerbosity = cms.untracked.bool(False),
    pythiaPylistVerbosity = cms.untracked.int32(1),
)
