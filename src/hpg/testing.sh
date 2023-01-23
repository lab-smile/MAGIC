#!/bin/sh
#SBATCH --job-name=MAGIC_TestModel
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=USER@ufl.edu # ADD EMAIL HERE
#SBATCH --ntasks=1
#SBATCH --mem=5gb
#SBATCH --time=00:10:00
#SBATCH --partition=gpu
#SBATCH --gpus=1
#SBATCH --output=hpg_testmodel_%j.out

date; hostname; pwd

#  Load environment (Option 1)
#===============================
module load conda
conda activate magic_env

#  Load environment (Option 2)   
#===============================
# If you have the location of your environment bin folder
#export PATH=/home/USER/.conda/envs/magic_env/bin:$PATH

#      Testing a Model    
#===========================
dataset="../sample"                        # Dataset path
save_root="results"                        # Name for saved root folder
model_path="../MAGIC_Generator_FINAL.pkl"  # Model path

python pytorch_pix2pix_test.py --dataset $dataset --save_root $save_root --model_path $model_path

date