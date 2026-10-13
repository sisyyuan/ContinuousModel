#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=16
#SBATCH --mem=500gb
#SBATCH --time=100:00:00
#SBATCH --partition=Draco
#SBATCH --job-name=9-DHS
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0

NonCRM=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/NonCRM.bed
TFBS_island=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/TFBS_island.bed
TFBS_spacer=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/TFBS_spacer.bed
DHS_Dir=/projects/zcsu_research1/ContinuousModel_SY/$1/9-DHS-$2/files
plotDHS=/projects/zcsu_research1/ContinuousModel_SY/9-plotDHS.py

cd $1
cd 9-DHS-$2
#################cat all DHS sites, get the summit region
#gunzip $DHS_Dir/*.bed.gz
#cat $DHS_Dir/*.bed | awk '{print $1,$2,$3}' OFS="\t" | sort -k1,1 -k2,2n --parallel=16 -T $PWD -u > DHS.bed
bedtools merge -i DHS.bed > DHS.merged.bed
#cat <(<$NonCRM awk -F "\t" '{print $0,"NonCRM"}' OFS="\t") <(<$TFBS_island awk -F "\t" '{print $0,"TFBS_island"}' OFS="\t") <(<$TFBS_spacer awk -F "\t" '{print $0,"TFBS_spacer"}' OFS="\t") | sort -k1,1 -k2,2n --parallel=16 -T $PWD > CRM.Types

bedtools intersect -a CRM.Types -b DHS.merged.bed > CRM.Types.DHS

awk '{Sum[$4]+=($3-$2)}END{for (i in Sum) {print i, Sum[i]}}' OFS="\t" CRM.Types > CRM.Types.Sum
awk '{Sum[$4]+=($3-$2)}END{for (i in Sum) {print i, Sum[i]}}' OFS="\t" CRM.Types.DHS > CRM.Types.DHS.Sum
awk '{Sum+=($3-$2);Count+=1}END{print Sum/Count}' DHS.bed > DHS.Length

<<EOF
#########summit
cat $DHS_Dir/*.bed | awk '{print $1,($2+$3),($2+$3)}' OFS="\t" | sort -k1,1 -k2,2n --parallel=16 -T $PWD -u > DHS-summit.bed
bedtools intersect -a CRM.Types -b DHS-summit.bed -c > CRM.Types.DHS.summit
awk '{$6=$5*1000/($3-$2);print}' OFS="\t" CRM.Types.DHS.summit > CRM.Types.DHS.summit.Density
python3 $plotDHS CRM.Types.DHS.summit.Density "NonCRM" "TFBS_island" "TFBS_spacer"
EOF

cd ..
cd ..
