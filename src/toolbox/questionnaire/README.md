# Description

This repo is the experimental design repository. The purpose of this repo is to take the data in the format from the MAGIC model and create an experiment. It does this by first constructing CT Column images within "separate_patients.m". It then, will shuffle and randomize the patients according to a seed, and will produce a file with the a mapping which shows which original patient corresponds to the CTP_0, CTP_1 format. Finally, the "extract_data.m" will decode the results from the doctors using the mappings created in the shuffle code to create graphs and do analysis.

## separate_patients.m
### Description 
```
Separate Patients will take the following file structure:
folder_with_images
       fake
           CBF
               ID_slice.bmp
               ID_slice.bmp
               ID_slice.bmp
           CBV
           MTT
           TMAX
       real
           NCCT
           CBF
           CBV
           MTT
           TMAX

It will produce this file structure:
   patients:
       ID_1
           fake_images (Column View with NCCT->CBV->CBF->MTT->TMAX)
           real_images (Column View with NCCT->CBV->CBF->MTT->TMAX)
       ID_2
           .
           .
           .
```
### Inputs:
#### all_image_path:
Path to the dataset which corresponds to folder_with_images in the above illustration. This is the data format which is outputted from the MAGIC model.

#### output_path:
Path to where the new file structure should be outputted. 

### patient list:
An excel file which indicates which patients to look for within the all_image_path.

## shuffle.m
### Description
Shuffle assumes the structure created in separate_patients.
   Shuffle first split each patient's real CTP and synthetic CTP into either category 0 and category 1. This corresponds to which part of the evaluation each CTP of a patient will be sent out. This is done so that within each experiment, a doctor only sees either the real or the synthetic CTP for a patient. This serves to eliminate bias which would arise from seeing the patient's data before within the experiment.

Shuffle then permutes the patients within category 0 and category 1 with different seeds. This is done to keep the experiment doubly blind and avoid confirmation bias.

## extract_data.m
### Description:
Extracts all the data from questionaires into a Cell called Data. The data is deshuffled according to the mappings created in "shuffle.m". The data is saved to two excel files: "GeneralResults.csv" and "DoctorResults.csv".

### Instructions for reproducing
#### Reproducing Evaluation
##### Set the "all_image_path" to path to REU > data > questionnaire. 
##### Set "output_path" to chosen location. 
##### Nothing in the import patient data needs to be changed.

#### Reproducing Shuffle
##### Run Shuffle with input variable set to the output_path from evaluation. Set the output variable to chosen output location.

#### Reproducing Extract Data
##### Set results1 variable to the doctor's excel responses for trail 1. Set results2 to the doctor's excel responses for trail 2.
Doctor's responses for trail 1 and trail 2 of evaluation 3 can be found in REU > Evaluation > Evaluation Archives > test3_20patients > evaluation_results. Of note, make sure to not copy over "Rajderkar evaluation_sheet.xlsx", copy "Rajderkar evaluation_sheet - Corrected.xlsx".
