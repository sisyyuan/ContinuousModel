#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=10gb
#SBATCH --time=100:00:00
#SBATCH --partition=DTN
#SBATCH --job-name=10-Download
#SBATCH --output=%x.out
#SBATCH --error=%x.err


cd $1
cd 10-WGBS-$2
mkdir files
cd files
xargs -L 1 curl -O -J -L < $3
gunzip *.bed.gz
cat *.bed  | awk '{print $1,$2,$3}' OFS="\t" > allWGBS.bed
cd ../../../
