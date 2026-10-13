#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=100gb
#SBATCH --time=10:00:00
#SBATCH --partition=Draco
#SBATCH --job-name=6-TAD
#SBATCH --output=%x.out
#SBATCH --error=%x.err


JuicerJar=/users/syuan4/Tools/juicer_tools_2.17.00.jar

cd $1
mkdir 6-TAD-$2
cd 6-TAD-$2
java -Xmx100g -jar $JuicerJar arrowhead $3 --threads 8 -k $4 -r $5  domains_$4
cd domains_$4
awk 'NR>2 {print $1,$2,$3,$3-$2}' OFS="\t" $5_blocks.bedpe | sort -k8,8nr | awk '{print $1,$2,$3}' OFS="\t" > $5.domains
cd ..
cd ../../


