#!/bin/sh
#SBATCH --job-name=MAGIC_TestModel
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kylebsee@ufl.edu # ADD EMAIL HERE
#SBATCH --ntasks=1
#SBATCH --mem=10gb
#SBATCH --time=1:00:00
#SBATCH --partition=hpg-ai
#SBATCH --gpus=a100:1
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
dataset="/blue/ruogu.fang/kylebsee/MAGIC/newput"                        # Dataset path
save_root="results"                        # Name for saved root folder
model_path="./MAGIC_Generator_FINAL-v2.pkl"  # Model path

python pytorch_pix2pix_test.py --dataset $dataset --save_root $save_root --model_path $model_path

date

python pytorch_pix2pix_test.py --dataset ../data/dataset_A2 --save_root results --model_path ../data/dataset_A2_results/models/dataset_A2_generator_param_final.pkl --batch_norm True

python pytorch_pix2pix_test.py --dataset ../data/new_augmented_data --save_root pretrain --model_path ./MAGIC_Generator_FINAL-v2.pkl --batch_norm True

