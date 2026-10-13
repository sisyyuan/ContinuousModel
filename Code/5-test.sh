#!/bin/bash

#K562_TAD_Dir=/projects/zcsu_research1/SisiYuan/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V2_HicObserved/Hic_Inter/K562:Erythroblast:Bone+Marrow_Folders/domains_SCALE
IMR90_TAD_Dir=/projects/zcsu_research1/SisiYuan/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V2_HicObserved/Hic_Inter/IMR90:Fibroblast:Lung_Folders/domains_SCALE

TestSlurm=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Correlation/5-test.slurm

Type=enhancer
GeneExpNum=0
CRMProbNum=5
Test=MWUtest

#for resolution in 5000 10000 25000 50000 100000 Merged;do
if [ ! -d IMR90 ];then
	mkdir IMR90
fi
cd IMR90

for resolution in 10000 25000 50000 100000 Merged;do
	if [ ! -d Res$resolution ];then
		mkdir Res$resolution
	fi
	cd Res$resolution
	cat $IMR90_TAD_Dir/$resolution.domains | while read domain;do
		sbatch $TestSlurm $domain $Test $CRMProbNum $Type $GeneExpNum
	done
	cd ..
done
cd ..
