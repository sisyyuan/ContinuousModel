#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --mem=50gb
#SBATCH --time=40:00:00
#SBATCH --partition=Orion
#SBATCH --job-name=6-TAD
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2023.09
module load bedtools2/2.29.0

TADs_Dir=/projects/zcsu_research1/SisiYuan/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V14/1-domainMergeAnalyses
hESC_TAD=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Correlation/2012BingRen/hESC.hg38.domains
IMR90_TAD=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Correlation/2012BingRen/Human-IMR90.hg38.domains
CRM=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/Human/7-Motif/TFBSs.unique.bed
plotDensity=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/6-TAD/6-plotTADdensity.py

sort -k1,1 -k2,2n --parallel=8 $CRM > CRM.motif.bed

######overlap with TADs
bedtools intersect -a CRM.motif.bed -b <(<$TADs_Dir/K562:Erythroblast:Bone+Marrow/Merged.domains sort -k1,1 -k2,2n) -u > CRMInTAD.bed
bedtools intersect -a CRM.motif.bed -b <(<$TADs_Dir/K562:Erythroblast:Bone+Marrow/Merged.domains sort -k1,1 -k2,2n) -u -f 1.0  > CRMsInMiddle.bed
#####on the boundary
bedtools subtract -a CRMInTAD.bed -b CRMsInMiddle.bed > CRMsInBoundary.bed 
echo "K562"
echo "K562" >> count.txt
wc -l CRMsInMiddle.bed >> count.txt
wc -l CRMsInBoundary.bed >> count.txt
######plot the density
cat <(<CRMsInMiddle.bed awk '{print $4*100/($3-$2)"\t""Middle"}') <(<CRMsInBoundary.bed awk '{print $4*100/($3-$2)"\t""Boundary"}') > TFBS.Density.Type.bed
python3 $plotDensity TFBS.Density.Type.bed TAD_mid_boundary K562


#########hESC
bedtools intersect -a CRM.motif.bed -b $hESC_TAD -u > CRMInTAD.bed
bedtools intersect -a CRM.motif.bed -b $hESC_TAD -u -f 1.0  > CRMsInMiddle.bed
bedtools subtract -a CRMInTAD.bed -b CRMsInMiddle.bed > CRMsInBoundary.bed
cat <(<CRMsInMiddle.bed awk '{print $4*100/($3-$2)"\t""Middle"}') <(<CRMsInBoundary.bed awk '{print $4*100/($3-$2)"\t""Boundary"}') > TFBS.Density.Type.bed
python3 $plotDensity TFBS.Density.Type.bed TAD_mid_boundary hESC
echo "hESC"
echo "hESC" >> count.txt
wc -l CRMsInMiddle.bed >> count.txt
wc -l CRMsInBoundary.bed >> count.txt

#########IMR90
bedtools intersect -a CRM.motif.bed -b $IMR90_TAD -u > CRMInTAD.bed
bedtools intersect -a CRM.motif.bed -b $IMR90_TAD -u -f 1.0  > CRMsInMiddle.bed
bedtools subtract -a CRMInTAD.bed -b CRMsInMiddle.bed > CRMsInBoundary.bed
cat <(<CRMsInMiddle.bed awk '{print $4*100/($3-$2)"\t""Middle"}') <(<CRMsInBoundary.bed awk '{print $4*100/($3-$2)"\t""Boundary"}') > TFBS.Density.Type.bed
python3 $plotDensity TFBS.Density.Type.bed TAD_mid_boundary IMR90
echo "IMR90"
echo "IMR90" >> count.txt
wc -l CRMsInMiddle.bed >> count.txt
wc -l CRMsInBoundary.bed >> count.txt


