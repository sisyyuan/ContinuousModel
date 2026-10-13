#!/bin/bash
DHSSlurm=/projects/zcsu_research1/ContinuousModel_SY/9-DHS.slurm
DLSlurm=/projects/zcsu_research1/ContinuousModel_SY/9-Download.slurm
DLfiles=/projects/zcsu_research1/ContinuousModel_SY/Mouse/9-DHS-300/mouse-files-DHS-bed.txt

species=Mouse
gap=300

#job_id=$(sbatch $DLSlurm $species $gap $DLfiles | awk '{print $4}')
#sbatch --dependency=afterok:$job_id $DHSSlurm $species $gap
sbatch $DHSSlurm $species $gap
