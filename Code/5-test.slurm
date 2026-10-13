#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=20gb
#SBATCH --time=4:00:00
#SBATCH --partition=Draco
#SBATCH --job-name=5-test
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2023.09
module load bedtools2/2.29.0

Test=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Correlation/5-test.py
GeneSubDir=/projects/zcsu_research1/SisiYuan/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V16_0Mark/5-Correlation/GeneExps.$7.Sub
CRMSubDir=/projects/zcsu_research1/SisiYuan/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V16_0Mark/5-Correlation/CRMProbs.$5.Sub

chr=$1
TADS=$2
TADE=$3

mkdir $1-$2-$3
cd $1-$2-$3
echo $1$'\t'$2$'\t'$3 > TAD.bed
################calculate the correlation between CRMs and genes within TADs. CRMs should be at least active and inactive in 5cell types
bedtools intersect -wa -wb -a TAD.bed -b $GeneSubDir/${chr}.bed.sort > TADgenes.bed
if [ -s TADgenes.bed ];then
	bedtools intersect -wa -wb -a TADgenes.bed -b $CRMSubDir/${chr}.bed.sort > TADgenesCRMs.bed
	if [ -s TADgenesCRMs.bed ];then
        #	python3 $Test TADgenesCRMs.bed $4 $5 $6
		##############randomly pick the same number of genes not in theTADs but on the same chromosome?? for CRMs to calculate the correalitons
		bedtools intersect -a $GeneSubDir/${chr}.bed.sort -b TAD.bed -v > GenesNotinTAD.bed
		n=$(wc -l <TADgenes.bed)
		shuf -n "$n" GenesNotinTAD.bed | awk -v chr=$1 -v TADs=$2 -v TADe=$3 '{print chr,TADs,TADe,$0}' OFS="\t" > TADoutgenes.bed
		bedtools intersect -wa -wb -a TADoutgenes.bed -b $CRMSubDir/${chr}.bed.sort > TADoutgenesCRMs.bed
		python3 $Test TADgenesCRMs.bed TADoutgenesCRMs.bed $1 $2 $3 $4 $5 $6
	fi
fi
cd ..

echo $1$'\t'$2$'\t'$3
