#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=20gb
#SBATCH --time=12:00:00
#SBATCH --partition=Nebula
#SBATCH --job-name=4-Predict
#SBATCH --output=%x.out
#SBATCH --error=%x.err

module load anaconda3/2020.11
module load bedtools2/2.29.0

CA_Model=/projects/zcsu_research1/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V16_0Mark/4-Train-Test/LogisticRegression-CA.joblib
PredictPy=/projects/zcsu_research1/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V16_0Mark/4-Predict-ENCODE.py
Total107Cells=/projects/zcsu_research1/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V16/13-DualCRM/Type/107EncodeCells
ENCODE_Dir=/projects/zcsu_research1/TargetGenePrediction_SY/CRMLocationStatesPredictionResultsPYN/Human_CRM_New/TarGenePre_V15/0-ENCODE

mkdir 4-Predict-ENCODE
cd 4-Predict-ENCODE
cat $Total107Cells | while read cell;do
	cell=${cell%?}
	if [ -f $ENCODE_Dir/EnhancerMarkers/$cell/CRMsMarkers.minmax ];then
                awk -F "," '{print $1,$2}' OFS="," $ENCODE_Dir/EnhancerMarkers/$cell/CRMsMarkers.minmax > $cell.CRM.minmax
        else
                awk -F "," '{print $1,$2}' OFS="," $ENCODE_Dir/SilencerMarkers/$cell/CRMsMarkers.minmax > $cell.CRM.minmax
        fi
done

python3 $PredictPy Training $PWD 0 $CA_Model CellName

cd ..
