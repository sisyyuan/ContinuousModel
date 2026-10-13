#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=40gb
#SBATCH --time=10:00:00
#SBATCH --partition=Orion
#SBATCH --job-name=10-CG
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0

NonCRM=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/NonCRM.bed
TFBS_island=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/TFBS_island.bed
TFBS_spacer=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/TFBS_spacer.bed
MouseGenome=/projects/zcsu_research1/ContinuousModel_SY/Mouse/mm10.fa

cd $1
cd 10-WGBS-$2
mkdir GC-content
cd GC-content
###########CG content
for file in $NonCRM $TFBS_island $TFBS_spacer;do
        filename=$(basename "$file")
        filename_no_extension="${filename%.*}"
	bedtools getfasta -fi $MouseGenome -bed $file -fo $filename_no_extension-CG_sequence.fa
	grep -v '^>' $filename_no_extension-CG_sequence.fa | tr -cd 'GCgc' | wc -m > $filename_no_extension-CG-Content
done

cd ../../..
