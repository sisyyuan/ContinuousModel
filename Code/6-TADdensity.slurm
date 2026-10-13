#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=10gb
#SBATCH --time=40:00:00
#SBATCH --partition=Orion
#SBATCH --job-name=6-TAD
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0

GenomeSize=/projects/zcsu_research1/ContinuousModel_SY/Mouse/mm10.chrom.sizes.20
TAD_Dir=/projects/zcsu_research1/ContinuousModel_SY/Mouse/6-TAD-300/domains_VC
CRM=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/CRM.bed
geneInfo=/projects/zcsu_research1/ContinuousModel_SY/Mouse/mart_export_03192024.txt
plotDensity=/projects/zcsu_research1/ContinuousModel_SY/Human/6-plotTADdensity.py

cd $1
mkdir 6-TAD-$2
cd 6-TAD-$2

<<EOF
####################TAD analysis
cat $TAD_Dir/*.domains > mm10.TADs
bedtools merge -i <(<mm10.TADs sort -k1,1 -k2,2n) > mm10.TAD
bedtools genomecov -i mm10.TAD -g <(<$GenomeSize sort -k1,1) > genome.coverage
bedtools intersect -a $CRM -b mm10.TAD -c > CRM.overlap
awk -v NumCRM=$(<$CRM wc -l) '{if ($4!=0) sum+=1}END {print sum/NumCRM}' CRM.overlap > CRM.overlap.count
awk 'NR>1&&$1!="MT"{print "chr"$1,$2,$3}' OFS="\t" $geneInfo | sort -k1,1 -k2,2n -k3,3n -u > geneInfo.bed
bedtools intersect -a geneInfo.bed -b mm10.TAD -c > gene.overlap
awk -v NumGene=$(<geneInfo.bed wc -l) '{if ($4!=0) sum+=1}END {print sum/NumGene}' gene.overlap > gene.overlap.count


bedtools subtract -a <(<$GenomeSize awk '{print $1,1,$2}' OFS="\t" | sort -k1,1 -k2,2n) -b <(<mm10.TAD sort -k1,1 -k2,2n) > NonTADs.bed
bedtools intersect -a <(<mm10.TAD sort -k1,1 -k2,2n) -b $CRM -c > TADCRM.bed
bedtools intersect -a <(<mm10.TAD sort -k1,1 -k2,2n) -b geneInfo.bed -c > TADGene.bed
bedtools intersect -a NonTADs.bed -b $CRM -c > NonTADCRM.bed
bedtools intersect -a NonTADs.bed -b geneInfo.bed -c > NonTADGene.bed

cat <(<TADCRM.bed awk '{print $4/($3-$2),"TAD"}' OFS="\t") <(<NonTADCRM.bed awk '{print $4/($3-$2),"NonTAD"}' OFS="\t") > CRMdensity.Type.bed
cat <(<TADGene.bed awk '{print $4/($3-$2),"TAD"}' OFS="\t") <(<NonTADGene.bed awk '{print $4/($3-$2),"NonTAD"}' OFS="\t") > Genedensity.Type.bed

python3 $plotDensity CRMdensity.Type.bed
python3 $plotDensity Genedensity.Type.bed


plotCRMGene=/projects/zcsu_research1/ContinuousModel_SY/4-plotCRMGene.py
paste -d $'\t' TADCRM.bed TADGene.bed | awk '{print $4,$8}' OFS="\t" > TAD.CRM.Gene.bed
python3 $plotCRMGene TAD.CRM.Gene.bed
paste -d $'\t' NonTADCRM.bed NonTADGene.bed | awk '{print $4,$8}' OFS="\t" > NonTAD.CRM.Gene.bed
python3 $plotCRMGene NonTAD.CRM.Gene.bed 
EOF

############get CRM and gene length, not numbers
plotCRMGene=/projects/zcsu_research1/ContinuousModel_SY/4-plotCRMGene.py
bedtools intersect -a <(<mm10.TAD sort -k1,1 -k2,2n) -b $CRM -wao | awk '{sum[$1"\t"$2"\t"$3]+=$7}END{for(i in sum)print i,sum[i]}' OFS="\t" | sort -k1,1 -k2,2n > TADCRM.Len.bed
bedtools intersect -a <(<mm10.TAD sort -k1,1 -k2,2n) -b <(<geneInfo.bed sort -k1,1 -k2,2n) -wao | awk '{sum[$1"\t"$2"\t"$3]+=$7}END{for(i in sum)print i,sum[i]}' OFS="\t" | sort -k1,1 -k2,2n > TADGene.Len.bed
bedtools intersect -a NonTADs.bed -b $CRM -wao | awk '{sum[$1"\t"$2"\t"$3]+=$7}END{for(i in sum)print i,sum[i]}' OFS="\t" | sort -k1,1 -k2,2n > NonTADCRM.Len.bed
bedtools intersect -a NonTADs.bed -b <(<geneInfo.bed sort -k1,1 -k2,2n) -wao | awk '{sum[$1"\t"$2"\t"$3]+=$7}END{for(i in sum)print i,sum[i]}' OFS="\t" | sort -k1,1 -k2,2n > NonTADGene.Len.bed
paste -d $'\t' TADCRM.Len.bed TADGene.Len.bed | awk '{print $4,$8}' OFS="\t" > TAD.CRM.Gene.Len.bed
python3 $plotCRMGene TAD.CRM.Gene.Len.bed
paste -d $'\t' NonTADCRM.Len.bed NonTADGene.Len.bed | awk '{print $4,$8}' OFS="\t" > NonTAD.CRM.Gene.Len.bed
python3 $plotCRMGene NonTAD.CRM.Gene.Len.bed

cd ../../
