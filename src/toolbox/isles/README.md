#  Description 
This repo creates the structure needed for the ISLES2018 Albert's model, and then once the ISLES model has been run, finds the average dice and median dice values for nifti image fileswhich contain probability maps. In specific, this code is written tohandle the output of Albert's ISLES2018 model. The input, identified inthe datasetPath variable, is exactly the output of the model.

There are only two files which should be run by the user: "create_structure.m" and "generate_dice.m". 

Create structure creates the file structure for both the synthetic and the real CTP labeling the synthetic by odd numbers in the inference.txt and real by even numbers.

Generate dice finds the aforementioned values.

## Create Structure

### Inputs:
#### synPath: 
path to dataset with synthetic CTP images, assumes output format from the MAGIC model.
#### testPath:
path to dataset with the real CTP images, assumes output format from the MAGIC model
#### outputPath:
path to where the structure for the ISLES will be printed.



## Generate dice
### Comments:
   It is assumed that ground truth and synthesized nifti probability maps
   alternate between even and odd. That is, each consequtive pair of
   images contain the synthesized and the ground truth probability maps.

### Inputs:
####   datasetPath : 
path to dataset with patients, importantly, structure of the patients within the dataset must be the output of the ISLES2018
       model with consequtive pairs containing one ground truth and one
       synthesized. 

####   Threshold: 
The threshold value for which to construct the binary masks.
       That is, values larger than the threshold in the probability maps
       will become 1 in the binary image and those strictly less than will
       be 0. Threshold value used by us is 0.45

####   save_path: 
If you wish to save figures, the desination folder


####   save_figs: 
0 or 1 to identify whether to save figures or not. 0 does
  not and 1 does.

#### Output:
  The median and average dice value for the dataset.
