#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=20gb
#SBATCH --time=4:00:00
#SBATCH --partition=Nebula
#SBATCH --job-name=5-Res
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load bedtools2/2.29.0

GenomeSize=/projects/zcsu_research1/SisiYuan/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V2_HicObserved/Hic_Inter/hg38.chrom.sizes.24
HiC_Dir=/projects/zcsu_research1/SisiYuan/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V2_HicObserved/Hic_Inter

#for cell in K562:Erythroblast:Bone+Marrow_Folders IMR90:Fibroblast:Lung_Folders;do
for cell in IMR90:Fibroblast:Lung_Folders;do
	echo $cell >> Results.txt
	for resolution in 5000 10000 25000 50000 100000 Merged;do
		median=$(awk '{print $3-$2}' $HiC_Dir/$cell/domains_SCALE/$resolution.domains | sort -n | awk '{a[NR]=$1} END{if(NR%2){print a[(NR+1)/2]} else{print (a[NR/2]+a[NR/2+1])/2}}') 
		echo "$resolution $median" >> Results.txt
		bedtools genomecov -i $HiC_Dir/$cell/domains_SCALE/$resolution.domains -g <(<$GenomeSize sort -k1,1) | grep $'genome\t1' >> Results.txt
	done
done
