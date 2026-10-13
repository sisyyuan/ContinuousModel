#!/bin/bash
CRMTSSSlurm=/projects/zcsu_research1/ContinuousModel_SY/5-CRMTSS.slurm

species=Human
gap=300

sbatch $CRMTSSSlurm $species $gap
