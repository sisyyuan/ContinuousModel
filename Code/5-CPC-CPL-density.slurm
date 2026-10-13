#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=10gb
#SBATCH --time=40:00:00
#SBATCH --partition=Orion
#SBATCH --job-name=5-CPC-CPL
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2023.09
module load bedtools2/2.29.0


geneInfo=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/Human/mart_export_hg38_05072024.txt
CRM=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/Human/7-Motif/TFBSs.unique.bed
plotDensity=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/6-TAD/6-plotTADdensity.py

bedtools intersect -a $CRM -b <(<$geneInfo awk 'length($1)<=5 && $1!="MT" {print "chr"$1,$5,$5}' OFS="\t" | sort -k1,1 -k2,2n -u) -wa | sort -u --parallel=16 -T $PWD > CorePromoterContainingCRM.bed
bedtools intersect -a $CRM -b <(<$geneInfo awk 'length($1)<=5 && $1!="MT" {print "chr"$1,$5,$5}' OFS="\t" | sort -k1,1 -k2,2n -u) -v | sort -u --parallel=16 -T $PWD > Non-CorePromoterContainingCRM.bed
cat <(<CorePromoterContainingCRM.bed awk '{print 100*$4/($3-$2),"CPC_CRM"}' OFS="\t") <(<Non-CorePromoterContainingCRM.bed awk '{print 100*$4/($3-$2),"CPL_CRM"}' OFS="\t") > CPC_CPL.bed

python3 $plotDensity CPC_CPL.bed CPC CPL
