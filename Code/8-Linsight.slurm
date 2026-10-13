#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=100gb
#SBATCH --time=100:00:00
#SBATCH --partition=Orion
#SBATCH --job-name=8-Linsight
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2023.09
module load bedtools2/2.29.0

CRM=/projects/zcsu_research1/ContinuousModel_SY/1-Proportion-300/CRM.bed
linsight=/projects/zcsu_research1/ContinuousModel_SY/human/LINSIGHT.bw
bw2bed=/projects/zcsu_research1/ContinuousModel_SY/human/bigWigToBedGraph

mkdir 8-Linsight
cd 8-Linsight

<<EOF
$bw2bed $linsight linsight.bedgraph
awk '{ \
    if ($1 ~ /^chr/) { \
        print $1"\t"$2"\t"$3"\tid-"NR"\t"$4; \
    } \
}' linsight.bedgraph \
> linsight.bed

#####download linsight data
wget http://compgen.cshl.edu/LINSIGHT/genomic_feature.bed.gz
wget http://compgen.cshl.edu/LINSIGHT/INSIGHT_database.ins.gz
gunzip genomic_feature.bed.gz
gunzip INSIGHT_database.ins.gz
EOF

###########get NonCRM, TFBS islands and spacers scores
NonCRM=/projects/zcsu_research1/ContinuousModel_SY/human/2-phyloP-300/NonCRM.bed
TFBS_island=/projects/zcsu_research1/ContinuousModel_SY/human/2-phyloP-300/TFBS_island.bed
TFBS_spacer=/projects/zcsu_research1/ContinuousModel_SY/human/2-phyloP-300/TFBS_spacer.bed
plotLinScore=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/Human/8-plotLinScore.py
liftOver=/projects/zcsu_research1/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V14/14-Validation/liftOver
hg19_38=/projects/zcsu_research1/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V14/14-Validation/hg19ToHg38.over.chain

############check if soordiante overlap
<<EOF
$liftOver linsight.bedgraph $hg19_38 linsight.bedgraph_h38 unmapped
sort -k1,1 -k2,2n --parallel=16 -T $PWD linsight.bedgraph_h38 | uniq > linsight.bedgraph_h38_sorted
>LinsightScore
for file in $TFBS_island $TFBS_spacer $NonCRM;do
	fileName=$(basename "$file")
	fileName_no_ext=$(echo "$fileName" | cut -d. -f1)
	bedtools intersect -a $file -b linsight.bedgraph_h38_sorted -wao > $fileName_no_ext\_linsight
	awk -v Type=$fileName_no_ext '{crm[$1":"$2"-"$3]+=$7*$8/($3-$2+1)}END{for (i in crm) {print i,crm[i],Type}}' OFS="\t" $fileName_no_ext\_linsight > $fileName_no_ext\_score 
	cat $fileName_no_ext\_score >> LinsightScore
done

Num=$(wc -l <LinsightScore)
sample_size=$((Num/100))
shuf -n $sample_size LinsightScore > LinsightScore0.01
python3 $plotLinScore LinsightScore0.01
EOF

<<EOF
mkdir 1bp
cd 1bp
bedtools intersect -a ../linsight.bedgraph_h38_sorted -b ../linsight.bedgraph_h38_sorted -c > linsight.bedgraph_h38_sorted_selfoverlap
awk '$5==1{print $1":"$2"-"$3,$4}' OFS="\t" linsight.bedgraph_h38_sorted_selfoverlap > linsight.bedgraph_h38_sorted_selfoverlap_no
awk '$5>1{print $1,$2,$3,$4}' OFS="\t" linsight.bedgraph_h38_sorted_selfoverlap > linsight.bedgraph_h38_sorted_selfoverlap_yes
awk '{for(i=$2;i<$3;i++) print $1,i,i+1,$4}' OFS="\t" linsight.bedgraph_h38_sorted_selfoverlap_yes > linsight.bedgraph_h38_sorted_selfoverlap_yes.1bp
awk '{count[$1":"$2"-"$3]+=1; crm[$1":"$2"-"$3]+=$4}END{for (i in crm) {print i,crm[i]/count[i]}}' OFS="\t" linsight.bedgraph_h38_sorted_selfoverlap_yes.1bp > linsight.bedgraph_h38_sorted_selfoverlap_yes.1bp.average
cat linsight.bedgraph_h38_sorted_selfoverlap_no linsight.bedgraph_h38_sorted_selfoverlap_yes.1bp.average | sed 's/[:-]/\t/g' | sort -k1,1 -k2,2n --parallel=32 -T $PWD > linsight.bedgraph_h38_sorted.1bp.average 


>LinsightScore
for file in $TFBS_island $TFBS_spacer $NonCRM;do
        fileName=$(basename "$file")
        fileName_no_ext=$(echo "$fileName" | cut -d. -f1)
        bedtools intersect -a $file -b linsight.bedgraph_h38_sorted.1bp.average -wao > $fileName_no_ext\_linsight
        awk -v Type=$fileName_no_ext '{crm[$1":"$2"-"$3]+=$7*$8/($3-$2)}END{for (i in crm) {print i,crm[i],Type}}' OFS="\t" $fileName_no_ext\_linsight > $fileName_no_ext\_score 
        cat $fileName_no_ext\_score >> LinsightScore
done

Num=$(wc -l <LinsightScore)
sample_size=$((Num/100))
shuf -n $sample_size LinsightScore > LinsightScore0.01
EOF

python3 $plotLinScore LinsightScore0.01 "NonCRM" "TFBS_island" "TFBS_spacer"

cd ..
cd ..



