#!/bin/sh
#SBATCH --job-name=dl_training_experiment
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=gfullerton@ufl.edu
#SBATCH --ntasks=1
#SBATCH --mem=400mb
#SBATCH --time=00:05:00
#SBATCH --output=dl_experiment_testing_%j.out

date;hostname;pwd

export PATH=/home/gfullerton/.conda/envs/py3/bin:$PATH

python pytorch_pix2pix_test.py --dataset new_augmented_data --save_root 'new_aug_learning_rate_1'

date


