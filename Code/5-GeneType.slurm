#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=50gb
#SBATCH --time=20:00:00
#SBATCH --partition=Nebula
#SBATCH --job-name=5-tau
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2023.09
module load bedtools2/2.29.0


if [ $1 == "Human" ];then
#	GeneExp=/projects/zcsu_research1/SisiYuan/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/$1_CRM_New/TarGenePre_V16_0Mark/5-Correlation/GeneExps
	GeneExp=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/5-GeneType-$1/ENCODE-RNAseq/GeneExps
fi

if [ $1 == "Mouse" ];then
	GeneExp=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/5-GeneType-$1/ENCODE-RNAseq/GeneExps
fi

plotTau=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/5-PlotGeneTypeTau.py

VistaEnhancer_D=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/TSS-Dis-cloEdge-$1/VistaEnhancer.Downstream.bed
VistaEnhancer_U=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/TSS-Dis-cloEdge-$1/VistaEnhancer.Upstream.bed
FantomEnhancer_D=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/TSS-Dis-cloEdge-$1/FantomEnhancer.Downstream.bed
FantomEnhancer_U=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/TSS-Dis-cloEdge-$1/FantomEnhancer.Upstream.bed
CRM_D=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/TSS-Dis-cloEdge-$1/CRM.Downstream.bed
CRM_U=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/TSS-Dis-cloEdge-$1/CRM.Upstream.bed
CRM_D_I=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/TSS-Dis-cloEdge-$1/CRM.Downstream.Intronic.bed
CRM_D_O=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/TSS-Dis-cloEdge-$1/CRM.Downstream.Outnic.bed
CRM_U_I=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/TSS-Dis-cloEdge-$1/CRM.Upstream.Intronic.bed
CRM_U_O=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/TSS-Dis-cloEdge-$1/CRM.Upstream.Outnic.bed


Exp=1
if [ -d 5-GeneType-$1 ];then
	mkdir 5-GeneType-$1
fi

cd 5-GeneType-$1/ENCODE-RNAseq
awk '{sum=0; for(i=2;i<=NF;i++){if ($i!=0) sum+=1}; print sum,$0}' OFS="\t" $GeneExp | awk -v Num=$Exp '{if($1>=Num) print}' OFS="\t" | cut -f2- > GeneExp$Exp
awk '{max=$2;for (i=3;i<=NF;i++) {if ($i>max) max=$i}; $(NF+1)=max; print $0}' OFS="\t" GeneExp$Exp > max.bed
awk '{sum=0;{for(i=2;i<=NF-1;i++) sum+=($NF-$i)/((NF-3)*$NF); print $0"\t"sum}}' OFS="\t" max.bed | sort -k1,1 > tau.bed

> taus.bed
#for type in $VistaEnhancer_U $VistaEnhancer_D $FantomEnhancer_U $FantomEnhancer_D $CRM_U $CRM_D;do
for type in $CRM_D_I $CRM_D_O $CRM_U_I $CRM_U_O;do
	filename=$(basename "$type" .bed)
	join <(<$type awk '{print $11}' | sort) tau.bed | awk -v Type=$filename '{print $NF,Type}' OFS="\t" > $filename.tau.bed
	cat $filename.tau.bed >> taus.bed 
done

awk -F'\t' -v OFS='\t' '{gsub(/\./, "\t", $2)} 1' taus.bed | sed -e 's/Intronic/Intragenic/g' -e 's/Outnic/Intergenic/g'  > temp && mv temp taus.bed
python3 $plotTau taus.bed Tau_CRM
cd ../..

