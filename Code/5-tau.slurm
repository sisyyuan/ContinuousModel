#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=20gb
#SBATCH --time=20:00:00
#SBATCH --partition=Nebula
#SBATCH --job-name=5-GeneType
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2023.09
module load bedtools2/2.29.0


ENCODE_Cell=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/5-GeneType-Human/ENCODE-RNAseq/folders.txt

cd ENCODE-RNAseq
cat $ENCODE_Cell | while read cell;do
        cd $cell
        num=$(find . -maxdepth 1 -type f -name "*RNA-seq.tsv*" | wc -l)
        cat *RNA-seq.tsv* | grep -v "_PAR_Y" | awk -v File_Num=$num '{ if ($1!="gene_id") {split($1, words, "."); $1=words[1];a[$1]+=$6}} END{for (i in a) print i"\t"a[i]/File_Num}' | sort -k1,1 --parallel=16 -T $PWD > RNA-seq.mean.bed ###########TPM
        cd ..
done

Exp_example=/projects/zcsu_research1/SisiYuan/ContinuousModel_SY/R1/5-CRMTSS/5-GeneType-Human/ENCODE-RNAseq/WTC11/RNA-seq.mean.bed
awk 'NR>1{print $1}' $Exp_example  > GeneExps

cat $ENCODE_Cell | while read cell;do
	join -t $'\t' GeneExps $cell/RNA-seq.mean.bed > temp && mv temp GeneExps
#       paste -d '\t' GeneExps <(<$cell/RNA-seq.mean.bed awk '{print $2}') > temp3 && mv temp3 GeneExps
done
