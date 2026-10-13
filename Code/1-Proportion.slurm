#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=100gb
#SBATCH --time=20:00:00
#SBATCH --partition=Orion
#SBATCH --job-name=1-Proportion
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load bedtools2/2.29.0
module load anaconda3/2020.11


CRM=/projects/zcsu_research/Sisi_CRMs/$1_CRM_New/ALL_CRMs_$2.pos_site.keep_pos_site.n-1.crm.score.sort.p_value
if [ $1 == "Mouse" ];then
	GenomeSize=/projects/zcsu_research1/ContinuousModel_SY/Mouse/mm10.chrom.sizes.20
	geneInfo=/projects/zcsu_research1/ContinuousModel_SY/Mouse/geneInfo.GRCm38_05032024.bed
else
	GenomeSize=/projects/zcsu_research1/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V2_HicObserved/Hic_Inter/hg38.chrom.sizes.24
fi

mkdir $1
cd $1
mkdir 1-Proportion-$2
cd 1-Proportion-$2

#############calculate the gene's proportion in the genome
#bedtools genomecov -i $geneInfo -g <(<$GenomeSize sort -k1,1) > gene.genomeCov.bed

<<EOF
##################NonCRM's genome coverage
NonCRM=/projects/zcsu_research/Sisi_CRMs/Non_Candidate_CRMs/$1_Non_Candiditate/TF_all_sort_motifs_unmerge.1000.bed.cat.clean.sort.merge.non_candidate
bedtools genomecov -i $NonCRM -g <(<$GenomeSize sort -k1,1) > NonCRM.genomeCov.bed


#############calculte the CRM's proportion in the genome
awk -v cutoff=$3 '{if($5>cutoff) print}' $CRM > CRM.bed
bedtools genomecov -i <(<CRM.bed awk '{print $1,$2,$3}' OFS="\t" | sort -k1,1 -k2,2n --parallel=16 -T $PWD) -g <(<$GenomeSize sort -k1,1) > CRM.genomeCov.bed

#############TFBS and merged TFBSs (island)
awk '{gsub(",","\n"$1"\t",$4);print $1,$4}' OFS="\t" CRM.bed | awk '{sub("+.*","",$2);print}' OFS="\t" | awk '{sub(/.*\|/,"",$2);print}' OFS="\t" | sed 's/:/\t/g' > TFBSs.bed
bedtools merge -i <(<TFBSs.bed sort -k1,1 -k2,2n --parallel=16 -T $PWD) > TFBS_islands.bed
bedtools genomecov -i TFBS_islands.bed -g <(<$GenomeSize sort -k1,1) > TFBS_islands.genomeCov.bed
bedtools genomecov -i <(<TFBSs.bed sort -k1,1 -k2,2n --parallel=16 -T $PWD) -g <(<$GenomeSize sort -k1,1) > TFBSs.genomeCov.bed

awk '{sum+=$3-$2}END{print sum}' TFBSs.bed > TFBSs.bed.length
awk '{sum+=$3-$2}END{print sum}' TFBS_islands.bed > TFBS_islands.bed.length
EOF

#################the distance between TFBSs and TFBS islands in each CRMs
plot=/projects/zcsu_research1/ContinuousModel_SY/1-plotDisLen.py

<<EOF
>TFBSs.distance.bed 
cat CRM.bed | while read CRM;do
	echo $CRM | awk '{gsub(",","\n"$1"\t",$4);print $1,$4}' OFS="\t" | awk '{sub("+.*","",$2);print}' OFS="\t" | awk '{sub(/.*\|/,"",$2);print}' OFS="\t" | sed 's/:/\t/g' | sort  --parallel=16 -T $PWD -u | sort -k1,1 -k2,2n --parallel=16 -T $PWD | awk '{a3[NR] = $3; a2[NR] = $2} END {for (i = 2; i <= NR; i++) print a2[i] - a3[i - 1]}' >> TFBSs.distance.bed 
done

>TFBS_islands.distance.bed 
cat CRM.bed | while read CRM;do
	echo $CRM | awk '{gsub(",","\n"$1"\t",$4);print $1,$4}' OFS="\t" | awk '{sub("+.*","",$2);print}' OFS="\t" | awk '{sub(/.*\|/,"",$2);print}' OFS="\t" | sed 's/:/\t/g' | sort -k1,1 -k2,2n | bedtools merge | awk '{a3[NR] = $3; a2[NR] = $2} END {for (i = 2; i <= NR; i++) print a2[i] - a3[i - 1]}' >> TFBS_islands.distance.bed  
done

cat <(<TFBSs.distance.bed awk '{print $1,"TFBS"}' OFS="\t") <(<TFBS_islands.distance.bed awk '{print $1,"TFBS_island"}' OFS="\t") > TFBS.islands.distance.bed
EOF

python3 $plot TFBS.islands.distance.bed -20 100

############the length of TFBSs and TFBS islands
#cat <(<TFBSs.bed sort -u --parallel=16 -T $PWD | awk '{print $3-$2,"TFBS"}' OFS="\t") <(<TFBS_islands.bed awk '{print $3-$2,"TFBS_island"}' OFS="\t") > TFBS.island.length.bed
python3 $plot TFBS.island.length.bed 8 50

cd ../..


