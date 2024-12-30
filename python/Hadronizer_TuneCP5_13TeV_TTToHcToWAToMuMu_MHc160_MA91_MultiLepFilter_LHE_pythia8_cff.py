import FWCore.ParameterSet.Config as cms

externalLHEProducer = cms.EDProducer("ExternalLHEProducer",
    args = cms.vstring("root://eosuser.cern.ch//eos/user/c/choij/HcToWA/gridpacks/TTToHcToWA_AToMuMu_MHc160_MA91_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz"),
    nEvents = cms.untracked.uint32(5000),
    numberOfParameters = cms.uint32(1),
    outputFile = cms.string('cmsgrid_final.lhe'),
    scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_xrootd.sh'),
    generateConcurrently = cms.untracked.bool(True),
)

from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunes2017.PythiaCP5Settings_cfi import *
from Configuration.Generator.PSweightsPythia.PythiaPSweightsSettings_cfi import *

generator = cms.EDFilter("Pythia8ConcurrentHadronizerFilter",
    maxEventsToPrint = cms.untracked.int32(1),
    pythiaPylistVerbosity = cms.untracked.int32(1),
    #filterEfficiency = cms.untracked.double(1.0),
    pythiaHepMCVerbosity = cms.untracked.bool(False),
    comEnergy = cms.double(13000.),
    PythiaParameters = cms.PSet(
        pythia8CommonSettingsBlock,
        pythia8CP5SettingsBlock,
        pythia8PSweightsSettingsBlock,
        parameterSets = cms.vstring('pythia8CommonSettings',
                                    'pythia8CP5Settings',
                                    'pythia8PSweightsSettings'
                                    )
    )
)

LeptonFilter = cms.EDFilter("MCMultiParticleFilter",
    AcceptMore  = cms.bool(True),
    NumRequired = cms.int32(3),
    ParticleID  = cms.vint32            (13 , -13, -13, -11,  13,  11, -13, -11, 13 , 11 , 13,  11, -13, -11),
    MotherID    = cms.untracked.vint32  (36 , 36 , 24 , 24 , -24, -24, 37 , 37 , -37, -37, 15 , 15 , -15, -15),
    PtMin       = cms.vdouble           (-1., -1., -1., -1., -1., -1., -1., -1., -1., -1., -1., -1., -1., -1.),
    EtaMax      = cms.vdouble           (1E6, 1E6, 1E6, 1E6, 1E6, 1E6, 1E6, 1E6, 1E6, 1E6, 1E6, 1E6, 1E6, 1E6),
    Status      = cms.vint32            (0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0)
)

LepKinFilter = cms.EDFilter("MCMultiParticleFilter",
    AcceptMore  = cms.bool(True),
    NumRequired = cms.int32(3),
    ParticleID  = cms.vint32(13, 11),
    MotherID    = cms.untracked.vint32(0, 0),
    PtMin       = cms.vdouble(5., 5.),
    EtaMax      = cms.vdouble(2.6, 2.6),
    Status      = cms.vint32(1, 1)
)

ProductionFilterSequence = cms.Sequence(generator*LeptonFilter*LepKinFilter)
