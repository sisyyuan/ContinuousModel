#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=16
#SBATCH --mem=300gb
#SBATCH --time=100:00:00
#SBATCH --partition=Draco
#SBATCH --job-name=3-getMarkTF
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2023.09
module load bedtools2/2.29.0

########also convert / to or
awk -F "\t" 'NR>1{print $6}' mm10_tranfac_QC.txt | sed -e 's/ /_/g' -e 's/\//or/g' | sort -u > mm10_tranfac_tissue.txt

awk -F "\t" 'NR>1{print $6}' mm10_chrmacc_QC.txt | sed -e 's/ /_/g' -e 's/\//or/g' | sort -u > mm10_chrmacc_tissue.txt

join mm10_tranfac_tissue.txt mm10_chrmacc_tissue.txt > mm10_train_cell.txt

GenomeSize=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/Mouse/mm10.chrom.sizes.20
geneInfo=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/Mouse/geneInfo.GRCm38_05032024.bed
CRM=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/Mouse/2-phyloP-300/CRM.bed
NonCRM=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/Mouse/2-phyloP-300/NonCRM.bed
getFeature=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Mouse/3-create_dataset_feature_single.py

CA_QC=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Mouse/mm10_chrmacc_QC.txt
CA_Dir=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Mouse/mm10_chrmacc
TF_QC=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Mouse/mm10_tranfac_QC.txt
TF_Dir=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Mouse/mm10_tranfac
Cells=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/Mouse/mm10_train_cell.txt
fraction=0.5

############positive CRMs in each cell type
mkdir Pos_Neg_Train_3
cd Pos_Neg_Train_3

cat $Cells | while read cell;do
	echo $cell
	sed -e 's/ /_/g' -e 's/\//or/g' $TF_QC | awk -v Cell=$cell '{if ($6==Cell) print $3}' > $cell.TF.list
	cat $cell.TF.list | while read record;do
		cat <(<$TF_Dir/$record\_* awk '{print $1,$2,$3,$7}' OFS="\t") >> $cell.TF.cat
	done
	sort -k1,1 -k2,2n --parallel=16 $cell.TF.cat > $cell.TF.cat.sort 

	sed -e 's/ /_/g' -e 's/\//or/g' $CA_QC | awk -v Cell=$cell '{if ($6==Cell) print $3}' > $cell.CA.list
	
	###############divided by the number of CA files
	CA_file_num=$(wc -l < $cell.CA.list)
	cat $cell.CA.list | while read record;do
		cat <(<$CA_Dir/$record\_* awk -v Num=$CA_file_num '$7!="." {print $1,$2,$3,$7/Num}' OFS="\t") >> $cell.CA.cat
	done
	sort -k1,1 -k2,2n --parallel=16 $cell.CA.cat > $cell.CA.cat.sort

	bedtools intersect -a $CRM -b $cell.TF.cat.sort -wa | uniq  > $cell.positive.bed
	positive_num=$(wc -l < $cell.positive.bed)
	shuf -n $positive_num $NonCRM > $cell.negative.bed

	###########positive set CA feature
	bedtools intersect -a $cell.positive.bed -b $cell.CA.cat.sort -f ${fraction} -F ${fraction} -e -wao > $cell.positive.CA.bed
	python3 $getFeature $cell.positive.CA.bed
	############negative set CA feature
	bedtools intersect -a $cell.negative.bed -b $cell.CA.cat.sort -f ${fraction} -F ${fraction} -e -wao > $cell.negative.CA.bed
	python3 $getFeature $cell.negative.CA.bed
done

cd ..

