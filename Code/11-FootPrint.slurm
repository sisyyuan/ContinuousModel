#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=50gb
#SBATCH --time=10:00:00
#SBATCH --partition=Nebula
#SBATCH --job-name=11-FT
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0

CRMType=/projects/zcsu_research1/ContinuousModel_SY/Human/9-DHS/CRM.Types
FootPrint=/projects/zcsu_research1/ContinuousModel_SY/Human/11-FootPrint/consensus_footprints_and_collapsed_motifs_hg38.bed
plotFootPrint=/projects/zcsu_research1/ContinuousModel_SY/Human/11-plotFootPrint.py

mkdir 11-FootPrint
cd 11-FootPrint

<<EOF
awk '{print $1,$9,$9}' OFS="\t" $FootPrint | grep -v NA > FootPrint.bed
bedtools intersect -a $CRMType -b FootPrint.bed -c > CRM.Types.FP
awk '{$6=$5*1000/($3-$2);print}' OFS="\t" CRM.Types.FP > CRM.Types.FP.Density
python3 $plotFootPrint CRM.Types.FP.Density "NonCRM" "TFBS_island" "TFBS_spacer"
EOF

<<EOF
awk '{print $1,$10,$11}' OFS="\t" $FootPrint | grep -v NA > FootPrint.bed
bedtools intersect -a $CRMType -b FootPrint.bed > CRM.Types.FP
awk '{Sum[$4]+=($3-$2)}END{for (i in Sum) {print i, Sum[i]}}' OFS="\t" CRM.Types.FP > CRM.Types.FP.Sum
awk '{Sum+=($3-$2);Count+=1}END{print Sum/Count}' FootPrint.bed > FootPrint.Length
EOF

mkdir consensus
cd consensus
awk '{print $1,$2,$3}' OFS="\t" $FootPrint | grep -v NA > FootPrint.bed
bedtools intersect -a $CRMType -b FootPrint.bed > CRM.Types.FP
awk '{Sum[$4]+=($3-$2)}END{for (i in Sum) {print i, Sum[i]}}' OFS="\t" CRM.Types.FP > CRM.Types.FP.Sum
awk '{Sum+=($3-$2);Count+=1}END{print Sum/Count}' FootPrint.bed > FootPrint.Length
cd ..
cd ..
