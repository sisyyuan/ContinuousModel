#!/bin/bash
getTAD=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/6-getDomains.slurm
densityTAD=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/6-TADdensity.slurm
HiC=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/Mouse/ENCFF909ODS.hic

species=Mouse
gap=300
normalization=SCALE

for resolution in  5000 10000 25000 50000 100000;do
	sbatch $getTAD $species $gap $HiC $normalization $resolution
done

#sbatch $densityTAD $species $gap
