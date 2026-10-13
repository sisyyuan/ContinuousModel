#!/bin/bash
DLSlurm=/projects/zcsu_research1/ContinuousModel_SY/10-Download.slurm
DLfiles=/projects/zcsu_research1/ContinuousModel_SY/Mouse/10-WGBS-300/mouse-files-WGBS-bed.txt

species=Mouse
gap=300

############download WGBS and cat
job_id=$(sbatch $DLSlurm $species $gap $DLfiles | awk '{print $4}')

############uniq sites merge
getMerge=/projects/zcsu_research1/ContinuousModel_SY/10-WGBS-chr.slurm
for chr in X Y {1..19};do
	sbatch --dependency=afterok:$job_id $getMerge $species $gap $chr
done

#########get CG information
getCG=/projects/zcsu_research1/ContinuousModel_SY/10-CG.slurm
sbatch $getCG $species $gap



