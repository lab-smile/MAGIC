# -*- coding: utf-8 -*-
"""
@author: kylebsee

Match NCCT and FSTROKE output slices. 

Changes from MATLAB version:
    - Updated print statements to be more descriptive and organized to why subjects are skipped.
"""

"""
What your data should look like (structure may vary):

[deidPath] (Input)
100221
    CTA_HEAD_PERF_AND_NECK_BRD_BM_I...
        1_CE_SUMMARY_HEAD-W-C
        2.0
        CTA_1.0_CE_Vol._Brain_CTA_-NECK
        HEAD_0.5_CE_4D-Vol._4D_CBP_DYNAMIC
        ...
    data_summary.csv
    data_summary.excel
        
[fstrokePath] (Input)
100221
    cbf.nii.gz
    cbv.nii.gz
    mtt.nii.gz
    peak.nii.gz
    tmax.nii.gz
    ttp.nii.gz
    
[partitionPath] (Output)
NCCT
    100221_46
    100221_55
    100221_64
    ...
MTT
    100221_46
    100221_55
    100221_64
    ...
TTP
    100221_46
    100221_55
    100221_64
    ...
CBF
    100221_46
    100221_55
    100221_64
    ...
CBV
    100221_46
    100221_55
    100221_64
    ...
"""

import os
import glob
import pydicom
import numpy as np

def create_folder(folder_path):
    """
    Create output folder in the partition folder. Input CTP map name.
    """
    folder_name = os.path.basename(folder_path)
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
        print(f"'{folder_name}' folder created.")
    else:
        print(f"'{folder_name}' folder already exists.")



def create_error_file(flagFile, errorFlagPath, subject, reason):
    reason2 = reason.replace(" ","_")
    with open(flagFile, 'w'):
        pass
    errorFlagFile = os.path.join(errorFlagPath, f"{reason2}_{subject}.txt")
    with open(errorFlagFile, 'w'):
        pass
    print(f"> Skipping {subject} - {reason}")


# Set the input folders
deidPath = r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\ct_deidentified"
fstrokePath = r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\fstroke_output"
partitionPath = r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\partition_py"

# Initialized variables
NCCT_slice_offset = 4; # How many offset slices from (not including) main slice (mm)
offset_range = NCCT_slice_offset*2+1; # Total range of main slice and both offset slices (mm)
dsize = 7; # Disk radius for morphological closing, used in Dr. Fang's PCT function 
ub = 200; # Upperbound used in Dr. Fang's PCT function
match_threshold = 2; # Maximum threshold for finding matching Perfusion map slice (mm)
subjects = os.listdir(deidPath) # Subject list in the directory
NCCT_include = {'without', 'W-O', 'NCCT', 'NON-CON', 'NON_CON'}; # Inclusion terms to search for NCCT
NCCT_exclude = {'bone', '0.5', 'soft_tissue', 'Untitled', 'MIP', 'Stack', 'Summary', 'CTA', 'SUB', 'Dynamic', 'Perfusion', 'Lung', 'Sft', 'Soft', 'Scanogram'}; # Exclusionary terms to serach for NCCT
CTP_include = {'0.5','CBP' ,'4D' ,'Perfusion' ,'Dynamic'}; # Inclusionary terms to search for CTP
CTP_exclude = {'2.0', 'MIP' ,'Untitled' ,'Stack' ,'Summary' ,'CTA' ,'SUB' ,'CTV' ,'Bone' ,'Soft' ,'Maps' ,'Body' ,'Axial' ,'Coronal' ,'Tissue' ,'Soft' ,'Sft' ,'Removed' ,'HCT' ,'Map' ,'With' ,}; # Exclusionary terms to search for CTP
exclude_slice = 5

"""
In the MATLAB equivalent script, matchNCCTandFSTROKE.m, there are scripts called fix_study() and fix_series() which are used here. The deidentified files on HPG and test files are already fixed so I cannot try test fixes here. Assume for now that data is fixed. Come back here to replace. Files can be found on the PHI computer.
"""
print("-------------------------------------------")
print("SKIPPING FIX STUDY AND SERIES...")


# Creating folders if needed
print("-------------------------------------------")
print("POPULATING FOLDERS...")
maps = ['NCCT', 'MTT', 'TTP', 'rCBF', 'rCBV']
for folder_name in maps:
    folder_path = os.path.join(partitionPath, folder_name)
    create_folder(folder_path)

# Checkpoint flag folder
flagPath = os.path.join(deidPath, 'completed')
create_folder(flagPath)

# Error log folders
errorFlagPath = os.path.dirname(deidPath)
errorFlagPath = os.path.join(errorFlagPath, 'error_flags')
create_folder(errorFlagPath)


# Slice Matching
print("-------------------------------------------")
print("BEGIN SLICE MATCHING...")
subjects = [item for item in subjects if item != 'completed']
for subject in subjects:
    
    # Initialize variable each subject
    NCCT_zcoords = {}
    CTP_zcoords = {}
    
    flagFile = os.path.join(flagPath, f"{subject}.txt")
    if os.path.exists(flagFile):
        print(f"> Skipping {subject} - Flag found")
        continue
        
    
    # List the series folder names
    subjPath = os.path.join(deidPath, subject)
    studies = os.listdir(subjPath)
    for folder in studies:
        studyPath = os.path.join(subjPath, folder)
        if os.path.isdir(studyPath):
            series = os.listdir(studyPath)
            break
            
        
    # Inclusion/Exclusion criteria for NCCT and CTP
    series_NCCT = [name for name in series if not any(term.lower() in name.lower() for term in NCCT_exclude)]
    series_NCCT = [name for name in series_NCCT if any(term.lower() in name.lower() for term in NCCT_include)]
    series_CTP = [name for name in series if not any(term.lower() in name.lower() for term in CTP_exclude)]
    series_CTP = [name for name in series_CTP if any(term.lower() in name.lower() for term in CTP_include)]
    
    # Grab NCCT files if they exist
    if len(series_NCCT) == 1:
        NCCT_files = glob.glob(os.path.join(studyPath, series_NCCT[0],'*.dcm'))
    else: # No series found or multiple series found. Throw a flag
        if not series_NCCT:
            create_error_file(flagFile,errorFlagPath,subject,'Missing NCCT')
            continue
        else:
            create_error_file(flagFile,errorFlagPath,subject,'More than one NCCT series found')
            continue
    
    # Grab any file from the CTP series. It doesn't matter which CTP we grab so we grab the file with the largest byte size. CTP files generally have 50-65MB, which is the most bytes any file in this study has.
    if len(series_CTP) == 1:
        try:
            CTP_files = glob.glob(os.path.join(studyPath, series_CTP[0],'*.dcm'))
            maxFilePath = max(CTP_files, key=os.path.getsize)
            CTP_file = pydicom.dcmread(maxFilePath)
        except:
            create_error_file(flagFile,errorFlagPath,subject,'Error loading CTP')
            continue
    else: # No series found or multiple series found. Throw a flag
        if not series_CTP:
            create_error_file(flagFile,errorFlagPath,subject,'Missing CTP')
            continue
        else:
            create_error_file(flagFile,errorFlagPath,subject,'More than one CTP series found')
            continue
    
    
    # Grab all of the z-coordinates from NCCT
    try:
        for NCCT_file in NCCT_files:
            NCCT = pydicom.dcmread(NCCT_file)
            z_coord = NCCT.ImagePositionPatient[2] # X Y Z format
            NCCT_zcoords[z_coord] = NCCT_file
    except:
        create_error_file(flagFile,errorFlagPath,subject,'Issue with NCCT coordinates')
        continue
    
    # Grab all of the z-coordinates from CTP (hidden deep within metadata)
    try:
        for i in range(len(CTP_file.PerFrameFunctionalGroupsSequence)):
            z_coord = CTP_file.PerFrameFunctionalGroupsSequence[i].PlanePositionSequence[0].ImagePositionPatient[2]
            CTP_zcoords[z_coord] = i+1
    except:
        create_error_file(flagFile,errorFlagPath,subject,'Issue with CTP coordinates')
        
    # Convert the z-coord keys into a usable matrix
    NCCT_zs = list(NCCT_zcoords.keys())
    CTP_zs = list(CTP_zcoords.keys())
    
    NCCT_zs = np.array(NCCT_zs)
    CTP_zs = np.array(CTP_zs)
    slice_num = 1
    
    for jj in range(exclude_slice, len(NCCT_zcoords)-exclude_slice):
        
        # Grab ONE NCCT z-coordinate
        NCCT_z = NCCT_zs[jj]
        print(NCCT_z)