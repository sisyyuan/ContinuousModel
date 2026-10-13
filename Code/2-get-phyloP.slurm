#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=16
#SBATCH --mem=200gb
#SBATCH --time=10:00:00
#SBATCH --partition=Nebula
#SBATCH --job-name=2-phyloP
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0

phylop60=/projects/zcsu_research1/ContinuousModel_SY/Mouse/mm10.60way.phyloP60way.bw

getphyloP60(){
	bwtool extract bed <(<$1 sort -u --parallel=16 -T $PWD) mm10.60way.phyloP60way.bw $1.60.phyloP
}

##############extract each base's conservation score 
cd $1
mkdir 2-phyloP-$2
cd 2-phyloP-$2

cp $phylop60 .
##################no 150 nonCRM availabel for Mouse
if [ "$2" -eq 300 ];then
	NonCRM=/projects/zcsu_research/Sisi_CRMs/Non_Candidate_CRMs/$1_Non_Candiditate/TF_all_sort_motifs_unmerge.1000.bed.cat.clean.sort.merge.non_candidate
else
	NonCRM=/projects/zcsu_research/Sisi_CRMs/$1_CRM_New/TF_all_sort_motifs_unmerge.1000.bed.cat.clean.sort.merge.non_candidate_150
fi
cp $NonCRM NonCRM.bed
getphyloP60 NonCRM.bed

CRM=/projects/zcsu_research1/ContinuousModel_SY/$1/1-Proportion-$2/CRM.bed
awk '{print $1,$2,$3}' OFS="\t" $CRM | sort -k1,1 -k2,2n --parallel=16 -T $PWD > CRM.bed
getphyloP60 CRM.bed

TFBS_island=/projects/zcsu_research1/ContinuousModel_SY/$1/1-Proportion-$2/TFBS_islands.bed
cp $TFBS_island TFBS_island.bed
getphyloP60 TFBS_island.bed

########TFBS spacer
bedtools multiinter -i $TFBS_island CRM.bed | awk '{if($5=="2") print $1,$2,$3}' OFS="\t" > TFBS_spacer.bed
getphyloP60 TFBS_spacer.bed

cd ../..
