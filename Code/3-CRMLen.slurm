#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=50gb
#SBATCH --time=40:00:00
#SBATCH --partition=Nebula
#SBATCH --job-name=3-CRMLen
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0

plotCRMLen=/projects/zcsu_research1/ContinuousModel_SY/3-plotCRMLen.py
CRM=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/CRM.bed
NonCRM=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/NonCRM.bed

cd $1
mkdir 3-CRMLen-$2
cd 3-CRMLen-$2
########CRM and NonCRM length
cat <(<$CRM awk '{print $3-$2,"CRM"}' OFS="\t") <(<$NonCRM awk '{print $3-$2,"NonCRM"}' OFS="\t") > CRM_NonCRM_Len.bed
python3 $plotCRMLen CRM_NonCRM_Len.bed 

#######Ratio of NonCRM/CRM length to check if CRMs are clustered or not
plotRatio=/projects/zcsu_research1/ContinuousModel_SY/3-plotRatio.py
#join -1 1 -2 2 -t $'\t' <(<$CRM awk '{print $1"-"$2,$1"-"$3}' OFS="\t" | sort -k1,1 --parallel=16 -T $PWD) <(<$NonCRM awk '{print $1"-"$2,$1"-"$3}' OFS="\t" | sort -k2,2 --parallel=16 -T $PWD) > CRM_Left_Match.bed

#join -1 2 -2 1 -t $'\t' <(<CRM_Left_Match.bed sort -k2,2 --parallel=16 -T $PWD) <(<$NonCRM awk '{print $1"-"$2,$1"-"$3}' OFS="\t" | sort -k1,1 --parallel=16 -T $PWD) | awk '{print $3,$2,$1,$4}' OFS="\t" > CRM_Left_Right_Match.bed

#sed 's/-/\t/g' CRM_Left_Right_Match.bed | awk '{print 2*($6-$4)/($8-$6+$4-$2)}' OFS="\t" > CRM_NonCRM_Ratio.bed
#python3 $plotRatio CRM_NonCRM_Ratio.bed
############only print ratio that NonCRMs length > 300
#sed 's/-/\t/g' CRM_Left_Right_Match.bed | awk '{if(($4-$2) > 300 && ($8-$6) > 300) print 2*($6-$4)/($8-$6+$4-$2)}' OFS="\t" > CRM_NonCRM_Ratio_300.bed
#python3 $plotRatio CRM_NonCRM_Ratio_300.bed

###########<300 and >=300 NonCRM seperately
#sed 's/-/\t/g' CRM_Left_Right_Match.bed | awk '{if (($4-$2)  < 300 || ($8-$6) < 300) print 2*($6-$4)/($4-$2+$8-$6),"<300"; else print 2*($6-$4)/($4-$2+$8-$6),">=300"}' OFS="\t" > Ratio.bed
#sed 's/-/\t/g' CRM_Left_Right_Match.bed | awk '{if (($8-$6) < 300) print ($6-$4)/($8-$6),"<300"; else print ($6-$4)/($8-$6),">=300"}' OFS="\t" > RightRatio.bed
#python3 $plotRatio RightRatio.bed
#sed 's/-/\t/g' CRM_Left_Right_Match.bed | awk '{if (($4-$2) < 300) print ($6-$4)/($4-$2),"<300"; else print ($6-$4)/($4-$2),">=300"}' OFS="\t" > LeftRatio.bed
#python3 $plotRatio LeftRatio.bed
#cat <(<LeftRatio.bed awk '{print $1,"Left"$2}' OFS="\t")  <(<RightRatio.bed awk '{print $1,"Right"$2}' OFS="\t") > Left_Right_Ratio.bed
#python3 $plotRatio Left_Right_Ratio.bed
cd ../..
