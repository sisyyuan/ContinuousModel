#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=20gb
#SBATCH --time=40:00:00
#SBATCH --partition=Orion
#SBATCH --job-name=4-geneCRM
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0
module load R/4.2.2

CRM=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/CRM.bed
GenomeSize=/projects/zcsu_research1/ContinuousModel_SY/Mouse/mm10.chrom.sizes.20
geneInfo=/projects/zcsu_research1/ContinuousModel_SY/Mouse/geneInfo.GRCm38_05032024.bed
plotCorr=/projects/zcsu_research1/ContinuousModel_SY/4-plotCorr.py
plotCRMGene=/projects/zcsu_research1/ContinuousModel_SY/4-plotCRMGene.py

cd $1
mkdir 4-GeneCRMCorr-$2
cd 4-GeneCRMCorr-$2
###########chromosome len, gene number and CRM numbers Corrs
##########overlaps
<<EOF
awk '{ if ($1 in count) { count[$1] +=1;} else { count[$1] = 1;} } END { for (val in count) print val"\t"count[val]}' $geneInfo | sort -k1,1 > geneNum.bed
bedtools merge -i $geneInfo | awk '{ if ($1 in len) { len[$1] += $3-$2;} else {len[$1] =$3-$2;} } END { for (val in len) print val"\t"len[val]}'  | sort -k1,1 > geneLength.bed
awk '{ if ($1 in count) { count[$1] +=1;} else { count[$1] = 1;} } END { for (val in count) print val"\t"count[val]}' $CRM | sort -k1,1 > CRMNum.bed
awk '{ if ($1 in len) {len[$1]+=$3-$2; } else {len[$1]=$3-$2 } } END { for (val in len) print val"\t"len[val] }' $CRM | sort -k1,1 > CRMLength.bed
sort -k1,1 $GenomeSize > GenomeSize.bed
paste -d '\t' <(<GenomeSize.bed awk '{print $2}') <(<CRMNum.bed awk '{print $2}') <(<CRMLength.bed awk '{print $2}') <(<geneNum.bed awk 'length($1)<=5 && $1!="chrMT" {print $2}') <(<geneLength.bed awk 'length($1)<=5 && $1!="chrMT" {print $2}') > Genome_CRM_Gene.bed
python3 $plotCorr Genome_CRM_Gene.bed
EOF

###########a sliding window of 1Mb overlapping with CRM and gene bps
#plotManhatton=/projects/zcsu_research1/ContinuousModel_SY/4-plotManhatton.R
#plotManhatton_zvalue=/projects/zcsu_research1/ContinuousModel_SY/4-plotManhatton-zvalue.R
plotManhatton=/projects/zcsu_research1/ContinuousModel_SY/$1/4-plotManhatton-zvalue.R
plotManhatton_Num=/projects/zcsu_research1/ContinuousModel_SY/$1/4-plotManhatton-num-zvalue.R

for window in 1000000 10000000;do
	step=$(($window/10))
<<EOF
	>Windows_$window\_$step.bed
	cat $GenomeSize | while read line;do
		Start=0
		End=$window
		read -r chr len _ <<< $line
		while [ "$End" -lt "$len" ];do
	       		echo $chr$'\t'$Start$'\t'$End >> Windows_$window\_$step.bed
	      		((Start+=$step))
	       		((End+=$step))
       		done
       	echo $chr$'\t'$((len-$window))$'\t'$len >> Windows_$window\_$step.bed
	done
EOF
	#############intersect with genes and CRMs, overlap bps
#	sort -k1,1 -k2,2n Windows_$window\_$step.bed > temp && mv temp Windows_$window\_$step.bed
#	bedtools intersect -a Windows_$window\_$step.bed -b $CRM -wao | awk '{a[$1"\t"$2"\t"$3]+=$7}END{for (i in a) print i"\t"a[i]}' | sort -k1,1 -k2,2n > Windows_$window\_$step.CRM.bed
#	bedtools intersect -a Windows_$window\_$step.bed -b <(<$geneInfo awk 'length($1)<=5{print $1,$2,$3}' OFS="\t" | sort -k1,1 -k2,2n -u) -wao | awk '{a[$1"\t"$2"\t"$3]+=$7}END{for (i in a) print i"\t"a[i]}' | sort -k1,1 -k2,2n > Windows_$window\_$step.Gene.bed
#	paste -d $'\t' Windows_$window\_$step.CRM.bed Windows_$window\_$step.Gene.bed | awk '{print $4,$8}' OFS="\t" > Windows_$window\_$step.CRM.Gene.bed
#	python3 $plotCRMGene Windows_$window\_$step.CRM.Gene.bed

##################Manhattan Plot
#	awk '{$1 = substr($1, 4); if($1=="X") $1=20; if($1=="Y") $1=21; print "Wd""_"$1"_"$2,$1,$2,$4}' OFS="\t" Windows_$window\_$step.Gene.bed > Windows_$window\_$step.Gene.Manhattan.bed
	Rscript $plotManhatton Windows_$window\_$step.Gene.Manhattan.bed 0.45 $window 
#	awk '{$1 = substr($1, 4); if($1=="X") $1=20; if($1=="Y") $1=21; print "Wd""_"$1"_"$2,$1,$2,$4}' OFS="\t" Windows_$window\_$step.CRM.bed > Windows_$window\_$step.CRM.Manhattan.bed
	Rscript $plotManhatton Windows_$window\_$step.CRM.Manhattan.bed 0.55 $window

##################overlap but only consider numbers of genes and CRMs within the window
#	bedtools intersect -a Windows_$window\_$step.bed -b $CRM -wao | awk '{if($7!=0) a[$1"\t"$2"\t"$3]+=1; else a[$1"\t"$2"\t"$3]=0}END{for (i in a) print i"\t"a[i]}' | sort -k1,1 -k2,2n > Windows_$window\_$step.CRM.Num.bed
#	bedtools intersect -a Windows_$window\_$step.bed -b <(<$geneInfo awk 'length($1)<=5{print $1,$2,$3}' OFS="\t" | sort -k1,1 -k2,2n -u) -wao | awk '{if($7!=0) a[$1"\t"$2"\t"$3]+=1; else a[$1"\t"$2"\t"$3]=0}END{for (i in a) print i"\t"a[i]}' | sort -k1,1 -k2,2n > Windows_$window\_$step.Gene.Num.bed	
#        paste -d $'\t' Windows_$window\_$step.CRM.Num.bed Windows_$window\_$step.Gene.Num.bed | awk '{print $4,$8}' OFS="\t" > Windows_$window\_$step.CRM.Gene.Num.bed
#        python3 $plotCRMGene Windows_$window\_$step.CRM.Gene.Num.bed
#	awk '{$1 = substr($1, 4); if($1=="X") $1=20; if($1=="Y") $1=21; print "Wd""_"$1"_"$2,$1,$2,$4}' OFS="\t" Windows_$window\_$step.Gene.Num.bed > Windows_$window\_$step.Gene.Num.Manhattan.bed
        Rscript $plotManhatton_Num Windows_$window\_$step.Gene.Num.Manhattan.bed $window 55364 2725521370 23639 
#        awk '{$1 = substr($1, 4); if($1=="X") $1=20; if($1=="Y") $1=21; print "Wd""_"$1"_"$2,$1,$2,$4}' OFS="\t" Windows_$window\_$step.CRM.Num.bed > Windows_$window\_$step.CRM.Num.Manhattan.bed
        Rscript $plotManhatton_Num Windows_$window\_$step.CRM.Num.Manhattan.bed $window 798257 2725521370 1894
done

cd ../..
