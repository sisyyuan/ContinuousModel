#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=16
#SBATCH --mem=100gb
#SBATCH --time=10:00:00
#SBATCH --partition=Orion
#SBATCH --job-name=7-Motif
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0

CRM=/projects/zcsu_research1/ContinuousModel_SY/$1/1-Proportion-$2/CRM.bed
TFBS=/projects/zcsu_research1/ContinuousModel_SY/$1/1-Proportion-$2/TFBSs.bed
TFBS_island=/projects/zcsu_research1/ContinuousModel_SY/$1/1-Proportion-$2/TFBS_islands.bed
TFBS_spacer=/projects/zcsu_research1/ContinuousModel_SY/$1/2-phyloP-$2/TFBS_spacer.bed
Count=/projects/zcsu_research1/ContinuousModel_SY/7-CountMotif.py
plotTFBS=/projects/zcsu_research1/ContinuousModel_SY/7-plotTFBSdensity.py
plot2=/projects/zcsu_research1/ContinuousModel_SY/1-plotDisLen2.py
plot=/projects/zcsu_research1/ContinuousModel_SY/1-plotDisLen.py

cd $1
mkdir 7-Motif-$2
cd 7-Motif-$2
############################the distance between TFBSs and TFBS islands in each CRMs
>TFBSs.distance.bed
cat $CRM | while read crm;do
        echo $crm | awk '{gsub(",","\n"$1"\t",$4);print $1,$4}' OFS="\t" | awk '{sub("+.*","",$2);print}' OFS="\t" | awk '{sub(/.*\|/,"",$2);print}' OFS="\t" | sed 's/:/\t/g' | sort  --parallel=16 -T $PWD -u | sort -k1,1 -k2,2n --parallel=16 -T $PWD | awk '{a3[NR] = $3; a2[NR] = $2} END {for (i = 2; i <= NR; i++) print a2[i] - a3[i - 1]}' >> TFBSs.distance.bed
done

>TFBS_islands.distance.bed
cat $CRM | while read crm;do
        echo $crm | awk '{gsub(",","\n"$1"\t",$4);print $1,$4}' OFS="\t" | awk '{sub("+.*","",$2);print}' OFS="\t" | awk '{sub(/.*\|/,"",$2);print}' OFS="\t" | sed 's/:/\t/g' | sort -k1,1 -k2,2n | bedtools merge | awk '{a3[NR] = $3; a2[NR] = $2} END {for (i = 2; i <= NR; i++) print a2[i] - a3[i - 1]}' >> TFBS_islands.distance.bed
done
cat <(<TFBSs.distance.bed awk '{print $1,"TFBS"}' OFS="\t") <(<TFBS_islands.distance.bed awk '{print $1,"TFBS_island"}' OFS="\t") > TFBS.islands.distance.bed
shuf -n 100000 TFBS.islands.distance.bed > TFBS.islands.distance.100000.bed
python3 $plot TFBS.islands.distance.100000.bed
python3 $plot TFBS.islands.distance.bed -20 100

############the length of TFBSs and TFBS islands
cat <(<TFBSs.bed sort -u --parallel=16 -T $PWD | awk '{print $3-$2,"TFBS"}' OFS="\t") <(<TFBS_islands.bed awk '{print $3-$2,"TFBS_island"}' OFS="\t") > TFBS.island.length.bed
shuf -n 100000 TFBS.island.length.bed > TFBS.island.length.100000.bed
python3 $plot TFBS.island.length.100000.bed
python3 $plot TFBS.island.length.bed 8 50

python3 $plot2 $TFBS_spacer 0 300

############################ TFBS density
>TFBSs.unique.bed
cat $CRM | while read crm;do
	echo $crm | awk '{gsub(",","\n"$1"\t"$2"\t"$3"\t",$4);print $1,$2,$3,$4}' OFS="\t" | awk '{sub("+.*","",$4);print}' OFS="\t" | awk '{sub(/.*\|/,"",$4);print}' OFS="\t" | sed 's/:/\t/g' | sort  --parallel=16 -T $PWD -u | awk '{a[$1"\t"$2"\t"$3]+=1}END{for (i in a) print i,a[i]}' OFS="\t" >>  TFBSs.unique.bed
done

awk '{print $4*100/($3-$2)}' OFS="\t" TFBSs.unique.bed > TFBS.density.bed
python3 $plotTFBS TFBS.density.bed TFBSdensity

cd ../..



