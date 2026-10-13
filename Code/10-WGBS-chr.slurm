#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=16
#SBATCH --mem=50gb
#SBATCH --time=100:00:00
#SBATCH --partition=Orion
#SBATCH --job-name=10-WGBS-chr
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0

allWGBS=/projects/zcsu_research1/ContinuousModel_SY/$1/10-WGBS-$2/files/allWGBS.bed
cd $1
cd 10-WGBS-$2
awk -v Chr="chr"$3 '$1==Chr' $allWGBS | sort -k1,1 -k2,2n --parallel=16 -T $PWD > "chr"$3.bed
bedtools merge -i "chr"$3.bed > "chr"$3.merged.bed
cd ../..
