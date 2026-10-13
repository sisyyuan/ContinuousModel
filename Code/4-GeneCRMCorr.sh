#!/bin/bash
GeneCRMSlurm=/projects/zcsu_research1/ContinuousModel_SY/4-GeneCRMCorr.slurm

species=Mouse
gap=300
sbatch $GeneCRMSlurm $species $gap
