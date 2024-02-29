# -*- coding: utf-8 -*-
"""
@author: kylebsee

Match NCCT and FSTROKE output slices.
It DOES NOT modify the original files.

Simplified overview: Repeat steps for each subject.
    1. Use NCCT and CTP keywords to identify NCCT and CTP folders.
    2. Load in NCCT files and one CTP file.
    3. Grab all z-coordinates from all NCCT slices and CTP slices*
    4. Remove the first {exclude_percent}% and last {exclude_percent}% slices.
    5. Construct pseudo-RGB NCCT and find closest matching {matching_threshold} CTP slice.
    6. Create mask based off NCCT. Remove eyes, skull, and fragments.
    7. Process CTP data.
    8. Concatenate NCCT and CTP (MTT, TTP, CBF, CBV) images and save.
    
*Each CTP slice contains all coordinates for all slices. NCCT coordinates are stored per file.

Changes from MATLAB version:
    - Updated print statements to be more descriptive and organized to why subjects are skipped.
    - Use morphological operations to improve mask.
    - Skips partition and processes individual maps immediately.
    - Substantially sped up NCCT processing.
    - Removed manual offset parameters. Replaced with percentage removal from start and end.
    - Now uses argparse to handle arguments. Callable in terminal.
    - Removed perfusion map folders.

===============================================================================
What your data should look like (exact wording may vary):

#---------#
#  INPUT  #
#---------#

[deidPath]
100221
    CTA_HEAD_PERF_AND_NECK_BRD_BM_I...
        1_CE_SUMMARY_HEAD-W-C
        2.0
        CTA_1.0_CE_Vol._Brain_CTA_-NECK
        HEAD_0.5_CE_4D-Vol._4D_CBP_DYNAMIC
        ...
    data_summary.csv
    data_summary.excel
        
[fstrokePath]
100221
    cbf.nii.gz
    cbv.nii.gz
    mtt.nii.gz
    peak.nii.gz
    tmax.nii.gz
    ttp.nii.gz


#----------#
#  OUTPUT  #
#----------#

[partitionPath]
100221_46
100221_50
100221_54
100221_58
100211_62
100211_66
...

"""

# Import libraries
import os, argparse, glob
 # Req. pylibjpeg + GDCM + pylibjpeg-libjpeg
from process_functions import create_folder, create_error_file, process_CTP, process_NCCT
import numpy as np
import matplotlib.pyplot as plt
import pydicom
import cv2
from tqdm import tqdm
#import time

parser = argparse.ArgumentParser()

#===================#
#  argument parser  #
#===================#

# Required paths
parser.add_argument('--deidPath', required=False, default=r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\ct_deidentified", help="Path containing deidentified UF Health data")
parser.add_argument('--fstrokePath', required=False, default=r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\fstroke_output", help="Path containing the fstroke output. Relates to the deidentified data")
parser.add_argument('--partitionPath', required=False, default=r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\partition_py", help="Path to contain image montage outputs")

"""
Above: Requires input folders.
Below: Optional variables to control matching sensitivity and morphological mask operations.
"""
parser.add_argument('--match_threshold', required=False, default=2, help="Maximum threshold (mm) for finding matching perfusion map slices")
parser.add_argument('--exclude_percent', required=False, default=0.3, help="Decimal percentage [0 1] of how many slices to exclude from the top and bottom of the 3D volume")
parser.add_argument('--dsize', required=False, default=7, help="Disk radius for morphological closing")
parser.add_argument('--ub', required=False, default=200, help="Upperbound")

#===================#

"""
Inclusion and exclusion terms to use for filtering NCCT and CTP keywords. These keywords are used to find the folders containing NCCT and CTP data. Folder names may vary subject to subject and these terms are not perfect.
"""
NCCT_include = {'without', 'W-O', 'NCCT', 'NON-CON', 'NON_CON'}; # Inclusion terms to search for NCCT
NCCT_exclude = {'bone', '0.5', 'soft_tissue', 'Untitled', 'MIP', 'Stack', 'Summary', 'CTA', 'SUB', 'Dynamic', 'Perfusion', 'Lung', 'Sft', 'Soft', 'Scanogram'}; # Exclusionary terms to serach for NCCT
CTP_include = {'0.5','CBP' ,'4D' ,'Perfusion' ,'Dynamic'}; # Inclusionary terms to search for CTP
CTP_exclude = {'2.0', 'MIP' ,'Untitled' ,'Stack' ,'Summary' ,'CTA' ,'SUB' ,'CTV' ,'Bone' ,'Soft' ,'Maps' ,'Body' ,'Axial' ,'Coronal' ,'Tissue' ,'Soft' ,'Sft' ,'Removed' ,'HCT' ,'Map' ,'With' ,}; # Exclusionary terms to search for CTP


# Load the arguments
opt = parser.parse_args()
print("Parsed Arguments:")
for arg, value in vars(opt).items():
    print(f"{arg}: {value}")
print("\n")

# Subject list in the directory
subjects = os.listdir(opt.deidPath)


"""
In the MATLAB equivalent script, matchNCCTandFSTROKE.m, there are scripts called fix_study() and fix_series() which are used here. The deidentified files on HPG and test files are already fixed so I cannot try test fixes here. Assume for now that data is fixed. Come back here to replace. Files can be found on the PHI computer.
"""
print("-------------------------------------------")
print("SKIPPING FIX STUDY AND SERIES...")


# Creating folders if needed
print("-------------------------------------------")
print("POPULATING FOLDERS...")
# Checkpoint flag folder
flagPath = os.path.join(opt.deidPath, 'completed')
create_folder(flagPath)

# Error log folders
errorFlagPath = os.path.dirname(opt.deidPath)
errorFlagPath = os.path.join(errorFlagPath, 'error_flags')
create_folder(errorFlagPath)

# Partition folder
create_folder(opt.partitionPath)

# Slice Matching. Skips if flag found in completed folder
print("-------------------------------------------")
print("BEGIN SLICE MATCHING...")
subjects = [item for item in subjects if item != 'completed']
with tqdm(total=len(subjects), desc='Processing Subjects') as pbar:
    for subject in subjects:
        
        pbar.update(1)
        
        # Initialize variable each subject
        NCCT_zcoords = {}
        CTP_zcoords = {}
        
        # Continue if subject is already completed, indicated by flag
        flagFile = os.path.join(flagPath, f"{subject}.txt")
        if os.path.exists(flagFile):
            print(f"> Skipping {subject} - Flag found")
            continue
            
        
        # List the series folder names
        subjPath = os.path.join(opt.deidPath, subject)
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
        
        """
        The image position patient metadata is saved differently in NCCT and CTP.
        Each NCCT slice contains its unique slice coordinates found in
        "ImagePositionPatient" metadata. Each CTP slice contains all slice coordinates
        for every slice. This is found in "PerFrameFunctionalGroupSequence". Since
        CTP is 0.5mm resolution it has 320 items in this metadata corresponding to
        each CTP slice. Further, the coordinates are found in "PlanePositionSequnece"
        then "ImagePositionPatient"
        
        We use a for loop to iterate through each slice for NCCT and each item in
        "PerFrameFunctionalGroupSequence" for the CTP slice.
        """
        
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
            continue
            
        # Convert the z-coord keys into a usable matrix using list then array fx.
        NCCT_zs = list(NCCT_zcoords.keys())
        CTP_zs = list(CTP_zcoords.keys())
        NCCT_zs = np.array(NCCT_zs)
        NCCT_zs_sorted = sorted(NCCT_zs)
        CTP_zs = np.array(CTP_zs)
        slice_num = 1
        
        # If no coordinates are found for either CTP or NCCT, throw an error
        if CTP_zs.size == 0:
            create_error_file(flagFile,errorFlagPath,subject,'CTP zero size array')
            continue
        elif NCCT_zs.size == 0:
            create_error_file(flagFile,errorFlagPath,subject,'NCCT zero size array')
            continue
        
        """
        Given a list of coordinates for the NCCT and CTP slices, we start slice
        matching NCCT and CTP. We exclude the first and last N slices from exclude
        slice variable. Each NCCT slice in the non-RAPID data have large deviations
        from each slice (5-15mm gap) so we process every non-excluded slice.
        """
        # More than 100 slices, save every 5 slices. Otherwise, expect ~10-30.
        if len(NCCT_zcoords) > 100:
            step_size = 4
        else:
            step_size = 1
        cutoff = round(len(NCCT_zcoords)*opt.exclude_percent)
        for jj in range(cutoff, len(NCCT_zcoords)-cutoff, step_size):
            
            # Grab ONE NCCT z-coordinate
            NCCT_z = NCCT_zs[jj]
            
            # Grab ONE corresponding CTP z-coordinate
            # !- Pass if we cannot find a corresponding CTP slice
            CTP_abs_value = np.min(np.abs(CTP_zs-NCCT_z)) # Find the value of the smallest absolute difference
            CTP_abs_index = np.argmin(np.abs(CTP_zs-NCCT_z)) # Find the index of the smallest absolute difference
            if CTP_abs_value >= opt.match_threshold: # Next slice if we cannot find a corresponding CTP coordinate
                continue
            CTP_z = CTP_zs[CTP_abs_index]
            correspondingCTPnumber = CTP_zcoords[CTP_z]
            
            # Grab TWO offset NCCT slices
            # !- NCCT slices are sometimes so far apart we just grab the above and below slice.
            idx = NCCT_zs_sorted.index(NCCT_z)
            try:
                above = NCCT_zs_sorted[idx+1]
                below = NCCT_zs_sorted[idx-1]
            except:
                continue
            
            # Get images using the z-coordinates. Access from zcoord dictionary
            NCCT_img_base_path = NCCT_zcoords[NCCT_z]
            NCCT_img_base = process_NCCT(NCCT_img_base_path, opt.ub, opt.dsize)
            
            # If <20% of the image is non-zero, skip slice
            if np.count_nonzero(NCCT_img_base) / NCCT_img_base.size < 0.2:
                continue
            
            # Process offset slices if base slice is informative
            NCCT_img_above_path = NCCT_zcoords[above]
            NCCT_img_above = process_NCCT(NCCT_img_above_path, opt.ub, opt.dsize)
            NCCT_img_below_path = NCCT_zcoords[below]
            NCCT_img_below = process_NCCT(NCCT_img_below_path, opt.ub, opt.dsize)
            
            # Clean brain slice to create mask
            binary_mask = NCCT_img_base != 0
            kernel = np.ones((3, 3), np.uint8)
            opening = cv2.morphologyEx(binary_mask.astype(np.uint8), cv2.MORPH_OPEN, kernel, iterations=4)
            mask = cv2.morphologyEx(opening, cv2.MORPH_CLOSE, kernel, iterations=2)
            
            # Find contours in the cleaned mask
            contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            
            # Create an empty mask to draw the brain region
            brain_mask = np.zeros_like(mask)
            
            if contours:
                largest_contour = max(contours, key=cv2.contourArea)
                cv2.drawContours(brain_mask, [largest_contour], 0, 255, thickness=cv2.FILLED)
            
            # Use dilation to refine the mask
            dilation_kernel = np.ones((3, 3), np.uint8)
            brain_mask = cv2.dilate(brain_mask, dilation_kernel, iterations=5)
            
            # Use erosion to remove skull
            erosion_kernel = np.ones((3, 3), np.uint8)
            brain_mask = cv2.erode(brain_mask, erosion_kernel, iterations=5)
            
            # Apply base slice mask to offset slices and base slice
            NCCT_img_base[~brain_mask.astype(bool)] = 0
            NCCT_img_above[~brain_mask.astype(bool)] = 0
            NCCT_img_below[~brain_mask.astype(bool)] = 0
            
            # Concatenate base and offset slices to create pseudo-3D image
            NCCT_img = np.stack([NCCT_img_below, NCCT_img_base, NCCT_img_above], axis=2)
            NCCT_img = np.interp(NCCT_img, (np.min(NCCT_img), np.max(NCCT_img)), [0,1])
            
            try:
                # Process CTP images
                MTT_img = process_CTP(opt.fstrokePath, subject, correspondingCTPnumber, mask, 'mtt')
                TTP_img = process_CTP(opt.fstrokePath, subject, correspondingCTPnumber, mask, 'ttp')
                CBF_img = process_CTP(opt.fstrokePath, subject, correspondingCTPnumber, mask, 'cbf')
                CBV_img = process_CTP(opt.fstrokePath, subject, correspondingCTPnumber, mask, 'cbv')
                
                # Apply NCCT mask for CTP images
                MTT_img[~brain_mask.astype(bool)] = 0
                TTP_img[~brain_mask.astype(bool)] = 0
                CBF_img[~brain_mask.astype(bool)] = 0
                CBV_img[~brain_mask.astype(bool)] = 0
            except:
                continue
            
            # Concatenate NCCT and all CTP slices
            final_img = np.hstack([NCCT_img, MTT_img, TTP_img, CBF_img, CBV_img])
            #plt.imshow(final_img)
            #plt.show()
            filename = os.path.join(opt.partitionPath,subject+'_'+str(jj)+'.png')
            plt.imsave(filename,final_img)
        
        
print("-------------------------------------------")
print("COMPLETED")
print("-------------------------------------------")
        
        
        