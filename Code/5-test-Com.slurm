#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=100gb
#SBATCH --time=150:00:00
#SBATCH --partition=Orion
#SBATCH --job-name=5-test-2
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2023.09
module load bedtools2/2.29.0

Test=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Correlation/5-test-Com.py
Plot=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Correlation/5-odds-ratio.py

TADs=*/
<<EOF
for tad in $TADs;do
	cd $tad
	cat Pvalue_inTAD.csv >> ../Pvalues_inTAD.csv
	cat Pvalue_NotinTAD.csv >> ../Pvalues_NotinTAD.csv
	cd ..
done
EOF

python3 $Test Pvalues_inTAD.csv Pvalues_NotinTAD.csv $1 $2
#python $Plot Pvalues_inTAD.csv Pvalues_NotinTAD.csv
