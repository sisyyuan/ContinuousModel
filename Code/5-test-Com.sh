#!/bin/bash

TestComSlurm=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Correlation/5-test-Com.slurm

Type=enhancer
GeneExpNum=0
CRMProbNum=5
Test=MWUtest

#for cell in IMR90 K562;do
for cell in K562;do
	cd $cell
	for resolution in 5000 10000 25000 50000 100000 Merged;do
	#for resolution in Merged;do
		cd Res$resolution
		sbatch $TestComSlurm $cell $resolution
		cd ..
	done
	cd ..
done

