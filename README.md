<p align="center">
  <img src="images/banner.png" width="750">
</p>

## About MAGIC

Developed by the Smart Medical Informatics Learning & Evaluation (SMILE) Laboratory, Dept. of Biomedical Engineering, University of Florida. 
- Originally created by Garrett Fullerton and Simon Kato.
- Under the supervision of Ruogu Fang, Ph.D.
- Currently maintained by Kyle See.

MAGIC is a novel, multitask deep network architecture that enables translation from non-contrast enhanced CT imaging to CT perfusion imaging maps. **This framework enables the synthesis of contrast-free perfusion imaging of the brain**. It is generalizable to other modalities of imaging as well.

The novelties of this framework for the synthesis of contrast-free perfusion imaging, in comparison to other modern image-to-image architectures, are as follows: 

- No existing framework to enable contrast-free perfusion imaging
- Physiologically-informed loss terms
- Multitask, simultaneous generation of four CTP maps 
- Shared encoding layers between perfusion maps
- Real-time, rapid generation of perfusion maps
- Improved spatial resolution of perfusion maps in the axial direction
- Generalizable to any additional perfusion maps
- Physicians-in-the-Loop Module

## Model Architectures

*Note: The pretrained MAGIC Generator is not publicly available. Any requests to access the pretrained model should be directed to [Kyle See](mailto:kylebsee@ufl.edu).*

The generator and discriminator networks can be found in [network.py](src/hpg/network.py). 

### Generator

The generator for MAGIC is a novel network architecture that was inspired by the popular _pix2pix_ network architecture, originally proposed an described by [_Isola, 2017_](https://arxiv.org/abs/1611.07004). The network accepts a [3x256x256] noncontrast enhanced CT pseudo-RGB input. The pseudo-RGB characteristic comes from the slice-stacking method used in preprocessing the data. The first four layers of the generator are simple encoding layers comprised of convolution layers. These are followed by batch normalization and leaky ReLU activation layers. This is referred to as the "Backbone Generator". The network diverges into 4 unique paths from the fifth layer, corresponding to each of the perfusion modalities. A series of transposed convolution layers are then used to upscale the encoded image at each pathway, which produces a final predicted perfusion series output. The generator's architecture is shown in greater detail in the figure below. 

<p align="center">
  <img src="images/generator.png">
</p>

### Discriminator

The discriminator utilizes a relatively simple _PatchGAN_ framework with a 70x70 pixel field of view. This method is originally proposed and described by [_Isola, 2018_](https://arxiv.org/abs/1611.07004v3). We utilize a binary cross entropy loss on the predicted labels for each synthesized and ground truth perfusion slice that the discriminator creates a prediction for. The discriminator's architecture is shown in the figure below.

<p align="center">
  <img src="images/discriminator.png">
</p>

## Pipeline Overview

The MAGIC pipeline includes <b>dataset processing, model training and validation, and model evaluation</b>. Dataset processing is <u>***currently only capable of handling UF Health data***</u> that has been deidentified using the [DICOM-Deidentification](https://github.com/lab-smile/DICOM-Deidentification) toolbox. Other datasets may be used but will require specific preparation. The input format of MAGIC is described in the [Dataset Processing](#dataset-processing) below.

The MAGIC model training outputs a .pkl model. This .pkl model is subsequently used to evaluate the test images. Checkpoint models can be enabled at certain epoch intervals to save a .pkl model snapshot.

The MAGIC evaluation scripts takes the output of the testing images along with the testing images itself to generate different comparisons between real and fake images. `generateSliceComparison`

We provide a small sample training and testing set for 


### Requirements

MATLAB code is known to work with MATLAB 2019b+

### Dataset Processing
MAGIC takes a *specific input* of a **horizontally concatenated 256-by-1280 montage of slices of NCCT, MTT, TTP, CBF, and CBV in that order**. Additionally, data needs to be split into train, val, and test folders. The models will separate the images by itself. The dataset processing pipeline of this repository specifically takes <u>***deidentified UF Health data***</u>. Any external dataset is not immediately compatible with this specific pipeline. External datasets simply need to meet the input requirements stated above to train or test with MAGIC.

- [matchNcctAndRapid.m](src/processing/matchNcctAndRapid.m) - Acquires pseudo-RGB NCCT slice and matching CTP slices.
- [partitionData.m](src/processing/partitionData.m) - Organizes CT-perfusion map folders and partitions data into train, val, and test.
- [concatenateMaps.m](src/processing/concatenateMaps.m) - Concatenate NCCT and CT-perfusion maps together.

>Training and result evaluation use a different order of perfusion maps. Training input uses NCCT, MTT, TTP, CBF, and CBV. Result evaluation displays NCCT, CBV, CBF, MTT, and TTP.

<p align="center">
  <img src="images/dataprocessing.png">
</p>

### Model Training
MAGIC model training outputs a .pkl model. This .pkl model is used for testing. 

- [pytorch_pix2pix.py](src/hpg/pytorch_pix2pix.py)
- [pytorch_pix2pix_test.py](src/hpg/pytorch_pix2pix_test.py)

### Evaluation

- [createPairedDataset.m](src/eval/createPairedDataset.m)
- [generateSliceComparison.m](src/eval/generateSliceComparison.m)
- [generateSliceReport.m](src/eval/generateSliceReport.m)


## Sample Dataset
We provide a small sample training set for evaluation and introduction to this project's code. This can be found in [rapid_set_split_small](src/sample/). Contained in this dataset are two subfolders, for training and testing a model. The [training set](src/sample/train) contains 48 samples, and the [testing set](src/sample/test) contains 10 samples. The original MAGIC model was trained on over 16,000+ individual samples, but this sample set illustrates the program's functionality.

Each data sample has been preprocessed using our [newp2pdataset.m](src/preprocessing/newp2pdataset.m) script to put the grayscale image data in a 1280x256 format. Each sample contains 5 images, each corresponding to a different modality. This is illustrated in the image below. From left to right, the image in each data sample are noncontrast CT, mean transit time (MTT), time-to-peak (TTP), cerebral blood flow (CBF), and cerebral blood volume (CBV). These 5 paired slices are put together in the same image file for the ease of loading data in while training our model. An example of a input sample is shown in the figure below.
![](https://github.com/lab-smile/MAGIC/blob/main/images/trainsample1.png?raw=true)

### 1. System Requirements
We recommend using the Linux operating system. All listed commands in this part are based on the Linux operation system. We highly recommend using a GPU system for computation, but these code and directions are compatible with CPU only. 

We used Linux (GNU/Linux 3.10.0-1062.18.1.el7.x86_64) and an NVIDIA TITAN X GPU with CUDA version 7.6.5.

### 2. Environment setup and Installation
We recommend installing Anaconda (https://www.anaconda.com/products/distribution#Downloads) to activate the appropriate Python environment with the following commands: 

- Download the repository
```
git clone https://github.com/lab-smile/MAGIC.git 

cd MAGIC/src/gpu 
```
- Create an environment with the required packages
```
conda env create -f magic_env.yml
```
- Activate the environment
```
conda activate magic_env
or
source activate magic_env
```
- Sample Dataset

After activate the required environment, navigate to the directory that contains the MAGIC model. You can find a sample dataset at
```
cd MAGIC/src/sample
```
We provide a small sample of deidentified NCCT and CTP image data for evaluation and experimentation. You can find two subfolders for training and testing the model within this directory. The training set contains 48 samples from 5 patients, and the testing set contains 10 samples from 1 patient.  
Each image sample has been preprocessed to a grayscale format and contains both the NCCT and CTP data for a given slice. Each image is presented in a 1280x256 montage. From left to right, the images comprising each sample are non-contrast CT, mean transit time (MTT), time-to-peak (TTP), cerebral blood flow (CBF), and cerebral blood volume (CBV). You can use this sample dataset for the following steps.

To train on the original dataset, set the dataset parameters in the following commands to the following path:
```
dataset = '/blue/ruogu.fang/gfullerton/pytorch-pix2pix/new_augmented_data'
```

### 3. GPU Server Training Instruction

Navigate to the directory that contains the Python script [pytorch_pix2pix.py](src/gpu/pytorch_pix2pix.py) for training.
```
cd MAGIC/src/gpu
```
Run the training script directly from the command line using the following command:  
```
python pytorch_pix2pix.py 
```
You can specify learning rates, output save direction, number of training epochs, etc. using command line arguments. For example:  
```
python pytorch_pix2pix.py --dataset '../sample' --lrG 0.00005 --lrD 0.00005 --train_epoch 50 --save_root 'results' 
```
After training, you will find: 

- A results folder containing the results of the training process, which is required for testing. The name of this folder is determined by the specified dataset and ```save_root``` arguments. For the above example, this folder will be titled ```/src/gpu/sample_results```. 

- ```sample_train_hist_[epoch_num].pkl``` and ```sample_train_hist_[epoch_num].png``` for visualization of how each loss terms changes during the course of training. 

- ```sample_generator_param_final.pkl``` and ```sample_discriminator_param.pkl```, each containing the fully trained generator and discriminator, respectively. 

For larger datasets, we recommend that running the training process inside of a screen session. Because the training process will take a long time for a large dataset, the screen session allow code runing in the backgroud. The program will continue to run even if you disconnect from the SSH server. You can establish a screen session using the following commands.
- Before activating the screen session, deactivate the base Python environment using the following command:
```
source deactivate
```
- Initialize a new screen session using the following command: 
```
screen
```
- Activate the Python environment and begin the training process using the same commands as above.
- Detach from the screen session
```
Press Ctrl+A to enter screen command mode (nothing will appear onscreen)
Press D to detach from the current screen
```
- You are now able to safely disconnect from the SSH server until the training process has completed.
When the training process is complete, reattach to the screen session using the following command: 
```
screen -dr
```

### 4. HiPerGator Training Instruction
HiPerGator (HPG) offers the benefit of increased processing speeds and access to high-power GPUs, but the interface is not as user-friendly as the lab's GPU server. On HPG, programs must be submitted as a batch SLURM script. These batch jobs can be submitted using the ```sbatch``` command, followed by the name of the corresponding shell (.sh) script.

Navigate to the directory that contains the shell script  [training.sh](src/hpg/training.sh) for training.
```
cd MAGIC/src/hpg/
```
The program inputs, environment path, and sbatch inputs are specified in this slurm script. The content of this shell script is shown below.
```bash
#!/bin/sh
#SBATCH --job-name=MAGIC_TrainModel
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=USER@ufl.edu        # ADD EMAIL HERE
#SBATCH --ntasks=8
#SBATCH --mem=10gb
#SBATCH --time=20:00:00
#SBATCH --partition=gpu
#SBATCH --gpus=1
#SBATCH --distribution=cyclic:cyclic
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
  --save_root $save_root\

date
```

You can specify the memory allocation, memory partitioning, and GPU type and number for the training process by directly modify this shell script. More information about constructing an sbatch shell script can be found on the [HPG wiki](https://help.rc.ufl.edu/doc/Getting_Started).

Running the training shell script by using the following command:
```
sbatch training.sh
```
This will submit your job in the processing queue, and the training process will begin once the appropriate resources become available. You can check the state of the task by using；
```
squeue -A [your_group_name]
```
You can now safely disconnect from the HPG server, and you will receive an email once your job is either complete, encounters an error, or runs out of memory.

## Testing Instruction
### 1. GPU Server Testing Instruction

Navigate to the directory that contains the Python script [pytorch_pix2pix_test.py](src/gpu/pytorch_pix2pix_test.py) for testing. 

Determine the ```dataset``` and ```save_root``` arguments. These should be the same specifications used for training. 

The perfusion information ratio of the PILO module can be optionally adjusted by specifying a value for the ```scale``` argument between 0 and 1. A higher perfusion information ratio results in increased perfusion representation in the generated maps, and a lower perfusion information ratio results in increased anatomic representation in the generated maps.  

After specifying the dataset and save_root arguments, run the test script using the following command: 
```
python pytorch_pix2pix_test.py --dataset '../sample' --save_root 'results' 
```
After running the test script, you will find: 
- A subfolder in the in the results folder titled ```test_results```. For the above example, this folder will be located under ```/src/gpu/sample_results/test_results```. 
### 2. HPG Server Testing Instruction
Similarly to the training process, the test script also need to be submitted as a batch job to HiPerGator in the form of a SLURM script. Navigate to the directory that contains the shell script [testing.sh](src/hpg/testing.sh) for testing.
```
cd MAGIC/src/hpg/
```
The content of this shell script is shown below.
```bash
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
```
You need to specify the dataset and the save_root as same as the specifications used in the [training.sh](src/hpg/training.sh) .

Running the testing shell script by using the following command:
```
sbatch testing.sh
```

## Postprocessing & Evaluation
### Figure Generation
Using the outputs of the [test script](src/gpu/pytorch_pix2pix_test.py), we can apply 3 different scripts to generate figures representing the synthesized series. The 3 scripts that we apply to generate these figures are as follows:
- [**generate_series.m**](src/eval/generate_series.m): Generates a series of figures containing the 4 CT perfusion modalities of a single slice.
- [**generate_fake_real_folder.m**](src/eval/generate_fake_real_folder.m): Used to apply a colormapto each perfusion image and save the outputs into a structure in which data is separated by modality and fake/real structure. 
- [**generate_combined_fig.m**](src/eval/generate_combined_fig.m): Generates a figure comparing the noncontrast-enhanced CT input, the ground truth perfusion output, and the synthesized perfusion output all in one figure for easy visualization. (note: this script is applied ***after*** generating the fake/real folder structure from the generate_series.m script)
![](https://github.com/lab-smile/MAGIC/blob/main/images/combined_fig_1.png?raw=true)

Each of these scripts require a path to a colormap that is applied to the grayscale outputs of the test script to produce the same colorings used in the RAPID protocol. This colormap is provided as part of this repository: [Rapid_Colormap.mat](src/eval/Rapid_Colormap.mat).

### Quantitative Metrics
To generate quantitative evaluation metrics for the outputs of the pytorch_pix2pix_test.py script, we use a [Jupyter Notebook script](src/eval/getmetrics.ipynb) in the eval folder titled [getmetrics.ipynb](src/eval/getmetrics.ipynb). If you have Anaconda installed, then Jupyter should have been installed as part of the installation. Otherwise, you can download Jupyter Notebook separately. Read [here](https://pythonforundergradengineers.com/opening-a-jupyter-notebook-on-windows.html#:~:text=Opening%20a%20Jupyter%20Notebook%20on%20Windows%201%20Anaconda,the%20Windows%20start%20menu.%20...%203%20Anaconda%20Navigator) for more information on opening Jupyter Notebook (.ipynb) files. 

We compute two metrics in our quantitative results evaluation:
- Structural Similarity Index Metric (SSIM)
- Universal Quality Index (UQI) 

Before running this script, make sure to change the paths associated with the following variables to correctly match the desired input and outputs used in your evaluation:
- ```datapath_real```: Path to folder containing original test data (e.g., ```src/sample/test```)
- ```datapath_fake```: Path to folder containing output from test script ([pytorch_pix2pix_test.py](src/gpu/pytorch_pix2pix_test.py))
- ```modelname```: Name of the model being tested (note: this has no impact on the metrics and is used solely for naming the output spreadsheet file)
- ```savepath```: Path to folder where the output file containing the quantitative image metrics should be saved (saved in .xlsx format)

## Acknowledgements
This work was financially supported by the National Science Foundation, IIS-1908299 III: Small: Modeling Multi-Level Connectivity of Brain Dynamics + REU Supplement, to the University of Florida and SMILE Laboratory.

## Contact
For any questions about this project, please contact [Kyle See](mailto:kylebsee@ufl.edu), or [Ruogu Fang, Ph.D](mailto:ruogu.fang@bme.ufl.edu).

## Last Updated
August 24, 2023