#!/bin/bash
GetSlurm=/projects/zcsu_research1/ContinuousModel_SY/2-get-phyloP.slurm
CatSlurm=/projects/zcsu_research1/ContinuousModel_SY/2-cat-phyloP.slurm

############
gap=300
species=Mouse
#first_job_id=$(sbatch $GetSlurm $species $gap | awk '{print $4}')
#sbatch --dependency=afterok:$first_job_id $CatSlurm $species $gap
sbatch $CatSlurm $species $gap
