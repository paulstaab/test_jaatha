#!/usr/bin/Rscript --no-save --no-site-file --no-init-file

arg <- commandArgs()
path <- '/scratch/paul/test_jaatha/lib'
cat("TEMPDIR: ", tempdir(), "\n")

last <- length(arg)
if (!is.na(arg[last])) {
  stopifnot(file.exists(arg[last]))
  jaatha.package <- arg[last]
} else {
  jaatha.package <- 'packages/jaatha_2.4-1.tar.gz'
}

library(testJaatha)
installPackageLocally(jaatha.package, path)

version <- as.character(packageVersion("jaatha"))


# Test a simple theta/tau/migration model
dm <- dm.createDemographicModel(c(20,25), 75)
dm <- dm.addSpeciationEvent(dm, 0.01, 5)
dm <- dm.addMutation(dm, 1, 10)
dm <- dm.addRecombination(dm, fixed=5)
dm <- dm.addSymmetricMigration(dm, .1, 2)
testJaatha:::testJaatha(dm, 3, 2, seed=12579, smoothing=FALSE, cores=c(16,2),
                        folder=paste('runs', version, 'tt.old', sep='/'))
testJaatha:::testJaatha(dm, 3, 2, seed=12579, smoothing=TRUE, cores=c(16,2),
                        folder=paste('runs', version, 'tt.sm', sep='/'))

# Test the fpc sum.stat
dm.fpc <- dm.createDemographicModel(c(20,25), 100)
dm.fpc <- dm.addSpeciationEvent(dm.fpc, 0.01, 5)
dm.fpc <- dm.addMutation(dm.fpc, 1, 10)
dm.fpc <- dm.addRecombination(dm.fpc, 1, 10)
dm.fpc <- dm.addSymmetricMigration(dm.fpc, .1, 2)
testJaatha:::testJaatha(dm.fpc, 2, 3, seed=124578, smoothing=FALSE, cores=c(16, 2),
                         folder=paste('runs', version, 'fpc', sep='/'),
                         fpc=TRUE)

# Test a finite sites model
dm.fs <- dm.setMutationModel(dm.fpc, "HKY", c(0.2, 0.2, 0.3, 0.3), 2)
testJaatha:::testJaatha(dm.fs, 2, 3, seed=124578, smoothing=FALSE, cores=c(16, 2),
                         folder=paste('runs', version, 'fs', sep='/'),
                         fpc=TRUE)

# Test a model with 5 parameters
dm.gro <- dm.createDemographicModel(c(24,25), 100, 1000)
dm.gro <- dm.addMutation(dm.gro, 1, 20, new.par.name="theta")
dm.gro <- dm.addSpeciationEvent(dm.gro, 0.001, 20, new.time.point.name="tau")
dm.gro <- dm.addSymmetricMigration(dm.gro, 0.005, 5, new.par.name="m")
dm.gro <- dm.addRecombination(dm.gro, fixed=5)
dm.gro <- dm.addSizeChange(dm.gro, 0.05, 10, population=2, at.time="0", new.par.name="q")
dm.gro <- dm.addParameter(dm.gro, par.name="s1", 0.05, 10)
dm.gro <- dm.addParameter(dm.gro, par.name="s2", 0.05, 10)
dm.gro <- dm.addSizeChange(dm.gro, par.new=FALSE, parameter="s1+s2", population=1, at.time="tau")
dm.gro <- dm.addGrowth(dm.gro, par.new=FALSE, parameter="log(1/s1)/tau", population=1)
dm.gro <- dm.addGrowth(dm.gro, par.new=FALSE, parameter="log(1/s2)/tau", population=2)
testJaatha:::testJaatha(dm.gro, 2, 1, seed=24680, smoothing=FALSE, cores=c(16, 2),
                        folder=paste('runs', version, 'gro.old', sep='/'))
testJaatha:::testJaatha(dm.gro, 2, 1, seed=24680, smoothing=TRUE, cores=c(16, 2),
                        folder=paste('runs', version, 'gro.sm', sep='/'))
