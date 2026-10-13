#!/bin/bash
CRMLenSlurm=/projects/zcsu_research1/ContinuousModel_SY/3-CRMLen.slurm

gap=300
species=Mouse
sbatch $CRMLenSlurm $species $gap
