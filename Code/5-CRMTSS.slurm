#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=10gb
#SBATCH --time=40:00:00
#SBATCH --partition=Orion
#SBATCH --job-name=5-CRMTSS
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0

liftOver=/projects/zcsu_research1/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V14/14-Validation/liftOver
CRM=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/CRM.bed
NonCRM=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/NonCRM.bed
plotCRMTSS=/projects/zcsu_research1/ContinuousModel_SY/5-plotCRMTSS.py
plotDisTSS=/projects/zcsu_research1/ContinuousModel_SY/5-plotDisTSS.py
plotLenTSS=/projects/zcsu_research1/ContinuousModel_SY/5-plotLenTSS.py

cd $1
/projects/zcsu_research1/ContinuousModel_SY/Mouse/mart_export_GRCm38_05032024.txtmkdir 5-CRMTSS-$2
cd 5-CRMTSS-$2

if [ "$1" == "Mouse" ]; then
	geneInfo=/projects/zcsu_research1/ContinuousModel_SY/Mouse/mart_export_GRCm38_05032024.txt
	VistaEnhancer=/projects/zcsu_research1/ContinuousModel_SY/Mouse/mm9.vistaEnhancer
	FantomPromoter=/projects/zcsu_research1/ContinuousModel_SY/Mouse/mm10_fair+new_CAGE_peaks_phase1and2.bed
	FantomEnhancer=/projects/zcsu_research1/ContinuousModel_SY/Mouse/F5.mm10.enhancers.bed
	mm9_10=/projects/zcsu_research1/ContinuousModel_SY/Mouse/mm9ToMm10.over.chain
	bedtools intersect -a $CRM -b <(<$geneInfo awk 'length($1)<=2 && $1!="MT"{print "chr"$1,$6,$6,$2,$3}' OFS="\t" | sort -k1,1 -k2,2n) -wa -wb > CRM.TSS.bed
bedtools intersect -a $NonCRM -b <(<$geneInfo awk 'length($1)<=2 && $1!="MT"{print "chr"$1,$6,$6,$2,$3}' OFS="\t" | sort -k1,1 -k2,2n) -wa -wb > NonCRM.TSS.bed
else
	geneInfo=/projects/zcsu_research1/ContinuousModel_SY/Human/mart_export_hg38_05072024.txt
	bedtools intersect -a $CRM -b <(<$geneInfo awk 'length($1)<=2 && $1!="MT"{print "chr"$1,$5,$5,$2,$3}' OFS="\t" | sort -k1,1 -k2,2n) -wa -wb > CRM.TSS.bed
bedtools intersect -a $NonCRM -b <(<$geneInfo awk 'length($1)<=2 && $1!="MT"{print "chr"$1,$5,$5,$2,$3}' OFS="\t" | sort -k1,1 -k2,2n) -wa -wb > NonCRM.TSS.bed
fi


<<EOF
##########CRM overlapping TSS - core-promoter-containg CRM length and TFBS difference compared with other CRMs
bedtools intersect -a $CRM -b <(<$geneInfo awk 'length($1)<=5 && $1!="MT" {print "chr"$1,$6,$6}' OFS="\t" | sort -k1,1 -k2,2n -u) -wa | sort -u --parallel=16 -T $PWD > CorePromoterContainingCRM.bed
bedtools intersect -a $CRM -b <(<$geneInfo awk 'length($1)<=5 && $1!="MT" {print "chr"$1,$6,$6}' OFS="\t" | sort -k1,1 -k2,2n -u) -v | sort -u --parallel=16 -T $PWD > Non-CorePromoterContainingCRM.bed
cat <(<CorePromoterContainingCRM.bed awk '{print $3-$2,"TSSContaining"}' OFS="\t") <(<Non-CorePromoterContainingCRM.bed awk '{print $3-$2,"Non-TSSContaining"}' OFS="\t") > CRM_TSS.bed
python3 $plotCRMTSS CRM_TSS.bed

#########Compare with Vista enhancers and Fantom promoters and enhancers
############Distance to closet TSS
awk 'length($1)<=5 && $1!="MT" {print "chr"$1,$6,$6,$4}' OFS="\t" $geneInfo | sort -k1,1 -k2,2n -k4,4 -u > TSS.info.bed
#$liftOver <(<$VistaEnhancer grep "positive" | grep -o '\<chr[^[:space:]]*' | sed 's/[:-]/\t/g') $mm9_10 VistaEnhancer_mm10 VistaEnhancer_unmapped
bedtools closest -a <(<VistaEnhancer_mm10 sort -k1,1 -k2,2n) -b TSS.info.bed -d -t first > VistaEnhancer_mm10_TSS 
bedtools closest -a <(<$FantomPromoter awk '{print $1,$2,$3}' OFS="\t" | sort -k1,1 -k2,2n) -b TSS.info.bed -d -t first > FantomPromoter_mm10_TSS
bedtools closest -a <(<$FantomEnhancer awk '{print $1,$2,$3}' OFS="\t" | sort -k1,1 -k2,2n) -b TSS.info.bed -d -t first > FantomEnhancer_mm10_TSS
bedtools closest -a $CRM -b TSS.info.bed -d -t first > CRM_TSS
cat <(<CRM_TSS awk '{print $8,"Our CRMs"}' OFS="\t") <(<VistaEnhancer_mm10_TSS awk '{print $8,"Vista Enhancers"}' OFS="\t") <(<FantomPromoter_mm10_TSS awk '{print $8,"Fantom Promoters"}' OFS="\t") <(<FantomEnhancer_mm10_TSS awk '{print $8,"Fantom Enhancers"}' OFS="\t") > Distance_TSS.bed
python3 $plotDisTSS Distance_TSS.bed

############# plot the length of CRMs, vista enhancers, fantom promoters/enhancers
cat <(<CRM_TSS awk '{if($8==0) $9="Overlap with TSS"; else $9="Not Overlap with TSS"; print $3-$2,$9,"Our CRMs"}' OFS="\t") <(<VistaEnhancer_mm10_TSS awk '{if($8==0) $9="Overlap with TSS"; else $9="Not Overlap with TSS"; print $3-$2,$9,"Vista Enhancers"}' OFS="\t") <(<FantomPromoter_mm10_TSS awk '{if($8==0) $9="Overlap with TSS"; else $9="Not Overlap with TSS"; print $3-$2,$9,"Fantom Promoters"}' OFS="\t") <(<FantomEnhancer_mm10_TSS awk '{if($8==0) $9="Overlap with TSS"; else $9="Not Overlap with TSS"; print $3-$2,$9,"Fantom Enhancers"}' OFS="\t") > Length_TSS.bed
python3 $plotLenTSS Length_TSS.bed

###############examples of CRMs overlapping fantom5/vista enhancer
bedtools intersect -a CorePromoterContainingCRM.bed -b FantomPromoter_mm10_TSS -wa -wb > CorePromoterContainingCRM.FantomPromoter.bed
bedtools intersect -a CorePromoterContainingCRM.bed -b FantomEnhancer_mm10_TSS -wa -wb > CorePromoterContainingCRM.FantomEnhancer.bed
bedtools intersect -a Non-CorePromoterContainingCRM.bed -b FantomEnhancer_mm10_TSS -wa -wb > Non-CorePromoterContainingCRM.FantomEnhancer.bed
bedtools intersect -a Non-CorePromoterContainingCRM.bed -b VistaEnhancer_mm10_TSS -wa -wb > Non-CorePromoterContainingCRM.VistaEnhancer.bed
EOF

plotDisTSS=/projects/zcsu_research1/ContinuousModel_SY/Human/5-plotDisTSS.py
CRM=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/CRM.bed
geneInfo=/projects/zcsu_research1/ContinuousModel_SY/Mouse/mart_export_GRCm38_05102024.txt
VistaEnhancer=/projects/zcsu_research1/ContinuousModel_SY/Mouse/5-CRMTSS-300/VistaEnhancer_mm10
FantomPromoter=/projects/zcsu_research1/ContinuousModel_SY/Mouse/mm10_fair+new_CAGE_peaks_phase1and2.bed
FantomEnhancer=/projects/zcsu_research1/ContinuousModel_SY/Mouse/F5.mm10.enhancers.bed
plotDisTSS=/projects/zcsu_research1/ContinuousModel_SY/Human/5-plotDisTSS.py

##############closest edge of CRMs
mkdir TSS-Dis-cloEdge
cd TSS-Dis-cloEdge
#cat <(<$CRM awk '{print $1,$2,$3,"CRM"}' OFS="\t") <(<$VistaEnhancer awk '{print $1,$2,$3,"VistaEnhancer"}' OFS="\t" | sort -u) <(<$FantomPromoter awk '$1!="chrM"{print $1,$2,$3,"FantomPromoter"}' OFS="\t" | sort -u) <(<$FantomEnhancer awk '{print $1,$2,$3,"FantomEnhancer"}' OFS="\t" | sort -u) | sort -k1,1 -k2,2n --parallel=16 -T $PWD > all.RE.bed
#awk 'NR>1&&length($1)<3&&$1!="MT"{print "chr"$1,$6,$6,$7}' OFS="\t" $geneInfo | sort -k1,1 -k2,2n > geneInfo.bed
#bedtools closest -a all.RE.bed -b geneInfo.bed -d -t first > all.RE.gene.bed
#awk -F "\t" '$9!=0&&$8==1&&$3<$6{$10=$3-$6;print $0} $9!=0&&$8==1&&$2>$6{$10=$2-$6;print $0} $9!=0&&$8==-1&&$3<$6{$10=$6-$3;print $0} $9!=0&&$8==-1&&$2>$6{$10=$6-$2;print $0} $9==0{$10=0;print $0}' OFS="\t" all.RE.gene.bed > all.RE.TSS.bed
#bedtools closest -a <(<all.RE.bed awk -F "\t" '{print $1,$2,$3,$4,"+"}' OFS="\t") -b <(<geneInfo.bed awk -F "\t" '{print $1,$2,$3,"b",1,$4}' OFS="\t") -D b > all.RE.TSS.Closest.bed
#awk '{print $10,$4}' OFS="\t" all.RE.TSS.bed > all.RE.TSS.Type.bed
#python3 $plotDisTSS all.RE.TSS.Type.bed

#awk '{if($9==0) $10="Overlap with TSS"; else $10="Not Overlap with TSS"; print $3-$2,$10,$4}' OFS="\t" all.RE.gene.bed > Length_TSS.bed
#python3 $plotLenTSS Length_TSS.bed
cd ..

<<EOF
###########midpoint of CRMs
mkdir TSS-Dis-Mid
cd TSS-Dis-Mid
cat <(<$CRM awk '{print $1,int($2/2+$3/2),int($2/2+$3/2),"CRM"}' OFS="\t") <(<$VistaEnhancer awk '{print $1,int($2/2+$3/2),int($2/2+$3/2),"VistaEnhancer"}' OFS="\t") <(<$FantomPromoter awk '$1!="chrM"{print $1,int($2/2+$3/2),int($2/2+$3/2),"FantomPromoter"}' OFS="\t") <(<$FantomEnhancer awk '{print $1,int($2/2+$3/2),int($2/2+$3/2),"FantomEnhancer"}' OFS="\t") | sort -k1,1 -k2,2n --parallel=16 -T $PWD > all.RE.bed
awk 'NR>1&&length($1)<3&&$1!="MT"{print "chr"$1,$6,$6,$7}' OFS="\t" $geneInfo | sort -k1,1 -k2,2n > geneInfo.bed
bedtools closest -a all.RE.bed -b geneInfo.bed -d -t first > all.RE.gene.bed
awk -F "\t" '$8==1{$10=$2-$6;print $0} $8==-1{$10=$6-$2;print $0}' OFS="\t" all.RE.gene.bed > all.RE.TSS.bed
awk '{print $10,$4}' OFS="\t" all.RE.TSS.bed > all.RE.TSS.Type.bed
#python3 $plotDisTSS all.RE.TSS.Type.bed
cd ..

mkdir TSS-Distance
cd TSS-Distance
cp ../TSS-Dis-cloEdge/all.RE.TSS.Type.bed ClosetEdge.Distance.bed
cp ../TSS-Dis-Mid/all.RE.TSS.Type.bed MidPoint.Distance.bed
for RE in CRM FantomEnhancer FantomPromoter VistaEnhancer;do
       cat <(<ClosetEdge.Distance.bed awk -v re=$RE '$2==re&&$1!=0{print $1,$2,"D-E"}' OFS="\t") <(<MidPoint.Distance.bed awk -v re=$RE '$2==re{print $1,$2,"D-M"}' OFS="\t") > $RE.distance.bed
#       python3 $plotDisTSS $RE.distance.bed
done
python3 $plotDisTSS VistaEnhancer.distance.bed 0.2
python3 $plotDisTSS FantomEnhancer.distance.bed 0
python3 $plotDisTSS FantomPromoter.distance.bed 0.4
python3 $plotDisTSS CRM.distance.bed 0
cd ..

#################3
mkdir FantomVistaEnhancerOverlap
cd FantomVistaEnhancerOverlap
bedtools intersect -a <(<$FantomEnhancer awk '{print $1,$2,$3}' OFS="\t" | sort -k1,1 -k2,2n) -b <(<$VistaEnhancer sort -k1,1 -k2,2n) -wo > EnhancerOverlap
cd ..
EOF
cd ../..
