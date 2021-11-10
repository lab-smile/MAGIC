#!/bin/sh
#SBATCH --job-name=dl_training_experiment
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=gfullerton@ufl.edu
#SBATCH --ntasks=8
#SBATCH --mem=7000mb
#SBATCH --time=20:00:00
#SBATCH --output=dl_experiment_%j.out
#SBATCH --partition=gpu
#SBATCH --gpus=quadro:1
#SBATCH --distribution=cyclic:cyclic

date;hostname;pwd

export PATH=/home/gfullerton/.conda/envs/py3/bin:$PATH

python pytorch_pix2pix.py --dataset 'new_augmented_data' \
	--lrG 0.00005 --lrD 0.00005 --extremabeta 10000 \
  --n_epochs_decay 50 --save_freq 10 --batch_size 8 \
  --test_batch_size 10 --save_root 'results_lr_5e-5' --n_epochs 50 --train_epoch 50

date
