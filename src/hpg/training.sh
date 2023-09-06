#!/bin/sh
#SBATCH --job-name=MAGIC_TrainModel
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=USER@ufl.edu        # ADD EMAIL HERE
#SBATCH --ntasks=8
#SBATCH --mem=10gb
#SBATCH --time=20:00:00
#SBATCH --partition=hpg-ai
#SBATCH --gpus=a100:1
#SBATCH --output=hpg_trainmodel_%j.out

date; hostname; pwd

#  Load environment (Option 1)
#===============================
module load conda
conda activate magic_env

#  Load environment (Option 2)   
#===============================
# If you have the location of your environment bin folder
#export PATH=/home/USER/.conda/envs/magic_env/bin:$PATH

#     Training a Model    
#===========================
dataset="../sample"   # Dataset path
lrG=0.00005           # Generator Learning Rate
lrD=0.00005           # Discriminator Learning Rate
train_epoch=50        # Number of epochs
save_root="results"   # Name for saved root folder

python pytorch_pix2pix.py --dataset $dataset \
	--lrG $lrG --lrD $lrD --train_epoch $train_epoch \
  --save_root $save_root

date


python pytorch_pix2pix.py --dataset ../data/dataset --lrG 0.00005 --lrD 0.00005 --train_epoch 50 --save_root results --num_workers 8 --batch_size 8