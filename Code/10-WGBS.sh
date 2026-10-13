#!/bin/bash

WGBSSlurm=/projects/zcsu_research1/ContinuousModel_SY/10-WGBS.slurm
species=Mouse
gap=300

sbatch $WGBSSlurm $species $gap

