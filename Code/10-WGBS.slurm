#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=16
#SBATCH --mem=500gb
#SBATCH --time=100:00:00
#SBATCH --partition=Draco
#SBATCH --job-name=10-WGBS
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0

CRMType=/projects/zcsu_research1/ContinuousModel_SY/$1/9-DHS-$2/CRM.Types
plotWGBS=/projects/zcsu_research1/ContinuousModel_SY/10-plotWGBS.py

cd $1
cd 10-WGBS-$2

>allWGBS.merged.bed
for chr in 1 10 11 12 13 14 15 16 17 18 19 2 3 4 5 6 7 8 9 X Y;do
	cat "chr"$chr.merged.bed >> allWGBS.merged.bed
done

#bedtools intersect -a $CRMType -b allWGBS.merged.bed -wao > CRM.Types.WGBS
#awk '{overlap[$1"-"$2"-"$3"-"$4]+=$8}END{for(i in overlap) {print i,overlap[i]}}' OFS="\t" CRM.Types.WGBS | sed 's/-/\t/g' | awk -F "\t" '{print $0,$5*10/($3-$2)}' OFS="\t" > CRM.Types.WGBS.overlap

#python3 $plotWGBS CRM.Types.WGBS.overlap "NonCRM" "TFBS_island" "TFBS_spacer"

bedtools intersect -a $CRMType -b allWGBS.merged.bed > CRM.Types.WGBS
awk '{Sum[$4]+=($3-$2)}END{for (i in Sum) {print i, Sum[i]}}' OFS="\t" CRM.Types.WGBS > CRM.Types.WGBS.Sum
awk '{Sum+=($3-$2)}END{print Sum}' allWGBS.merged.bed > allWGBS.merged.Length
cd ../..
