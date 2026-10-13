#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=20gb
#SBATCH --time=10:00:00
#SBATCH --partition=Orion
#SBATCH --job-name=2-catphyloP
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0

plotPhyloP=/projects/zcsu_research1/ContinuousModel_SY/2-plotPhyloP.py
cd $1
cd 2-phyloP-$2

###########cat all the phyloP score and plot them,1% of CRM and NonCRMs TFBS islands and spacers, 35 way
for way in 60;do
<<EOF
	###########split NonCRM into <300 and >=300 length
	#awk '{if(($3-$2) <300) print}' NonCRM.bed.$way.phyloP > NonCRM_S300.bed.$way.phyloP
        #awk '{if(($3-$2) >=300) print}' NonCRM.bed.$way.phyloP > NonCRM_G300.bed.$way.phyloP
	phyloPs=*.bed.$way.phyloP
	>PhyloPs0.01.$way
	>PhyloPs.$way
	for phylop in $phyloPs;do
		total_num=$(<$phylop wc -l)
		shuf -n $((total_num/100)) $phylop > $phylop\0.01 
		cat <(<$phylop\0.01 awk '{print $5}' | sed 's/,/\n/g' | awk -v type=${phylop/".bed.$way.phyloP"} '{print $1"\t"type}') >> PhyloPs0.01.$way
		cat <(<$phylop awk '{print $5}' | sed 's/,/\n/g' | awk -v type=${phylop/".bed.$way.phyloP"} '{print $1"\t"type}') >> PhyloPs.$way
	done
EOF
	python3 $plotPhyloP PhyloPs0.01.$way 0.01.$way "NonCRM" "TFBS_island" "TFBS_spacer"
	#python3 $plotPhyloP PhyloPs.$way $way "NonCRM" "TFBS_island" "TFBS_spacer" 	
done
cd ../..
