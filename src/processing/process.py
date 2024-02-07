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
import pydicom # Req. pylibjpeg + GDCM + pylibjpeg-libjpeg
import numpy as np
import cv2
from scipy.ndimage import label, generate_binary_structure, binary_closing, binary_opening, rotate
from skimage import exposure
from skimage.transform import resize
import nibabel as nib
import scipy.io

from matplotlib.colors import ListedColormap
import matplotlib.pyplot as plt
#import time


def create_folder(folder_path):
    """
    Create output folder in the partition folder. Uses given CTP map name.
    
        folder_path (str) - The name of the folder to be placed.
    """
    folder_name = os.path.basename(folder_path)
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
        print(f"'{folder_name}' folder created.")
    else:
        print(f"'{folder_name}' folder already exists.")



def create_error_file(flagFile, errorFlagPath, subject, reason):
    """
    Function to write an error file with a reason for the error. Should be
    given the same flag file, error flag path, and subject. Expect only the 
    reason (str) to change since it explains crash.
    
        flagFile (str)      - Path to expected flag file.
        errorFlagPath (str) - Path to the error log folder.
        subject (str)       - 6-digit number of subject.
        reason (str)        - Reason for the error.
    """
    # Replace spaces to underscores for a savable reason
    reason2 = reason.replace(" ","_")
    
    # Create an empty flag file
    with open(flagFile, 'w'):
        pass
    
    # Create an error flag file
    errorFlagFile = os.path.join(errorFlagPath, f"{reason2}_{subject}.txt")
    with open(errorFlagFile, 'w'):
        pass
    
    # Print reason
    print(f"> Skipping {subject} - {reason}")


def process_CTP(fstrokePath, subject, loc, mask, CTPType):
    """
    Function to process the perfusion maps. Should be given the same partition
    path, subject name, loc, jj, and mask. Only the data path and ctpMap should
    change for each pefusion map type.
    
        fstrokePath (str)   - Path to CTP perfusion map
        
    clip_limit higher values make it way brighter. Lower makes it darker.
    """
    # Construct file path for sub-folder CTP map and read CTP slice in
    dataPath = os.path.join(fstrokePath,subject,CTPType+'.nii.gz') 
    info = nib.load(dataPath)
    img = info.get_fdata()
    
    #colormap_var = scipy.io.loadmat(r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\rapid_colormap.mat")
    #colormap = colormap_var['Rapid_U']
    #custom_colormap = ListedColormap(colormap)
    
    slice_index = loc
    print("YES")
    img_slice = rotate(img[:,:,slice_index], 270) # Rotate so anterior faces up
    img_slice = np.interp(img_slice, (np.min(img_slice), np.max(img_slice)), [0,1]) # Normalize between 0 and 1
    #clip_limit = 1.5 * np.std(img_slice)
    #img_slice = exposure.equalize_adapthist(img_slice, clip_limit=clip_limit) # Apply adaptive histogram with clip limit
    clahe = cv2.createCLAHE(clipLimit=5.0, tileGridSize=(8, 8))
    img_slice = clahe.apply((img_slice * 255).astype(np.uint8)) / 255.0  # Convert back to [0, 1] range
    img_slice = resize(img_slice, (256, 256), anti_aliasing=True) # Resize to 256 by 256
    
    img_slice[~mask] = 0 # Apply a mask
    #img_slice = (img_slice*255).astype(np.uint8) # Convert to uint8
    #img_slice = custom_colormap(img_slice)
    #img_slice = img_slice[:,:,:3]
    plt.imshow(img_slice, cmap='gray')
    plt.title(CTPType)
    plt.show()
    
    img_slice = np.stack([img_slice, img_slice, img_slice], axis=-1)
    
    return img_slice

def process_NCCT(filePath, ub, dsize):
    """
    Function to process NCCT files. Read dicom files (req. PyDicom), convert to
    uint8 and rescale the image data, apply a harsh then smooth mask using
    pct_brainMask_noEyes from Dr. Fang's PCT toolbox, then resize to 256x256.
    
        filePath (str) - Path to dicom image
        ub (int)       - Upper bound 
        dsize (int)    - Disk radius for morphological closing
        
    Adapted using convert_dicom_to_uint8.m and pct_brainMask_noEyes.m from 
    /MAGIC/src/toolbox/utilities.
    
    CHANGED FROM BELOW. Substantial speed-up!
    Took 27.44 sec. New vectorized code takes 0.06 sec.
    
    for i in range(img.shape[0]):
        for j in range(img.shape[1]):
            new_img[i,j] = img[i,j] * info.RescaleSlope + info.RescaleIntercept
            if new_img[i,j] < (info.WindowCenter-info.WindowWidth/2):
                output_img[i,j] = 0
            else:
                if new_img[i,j] > (info.WindowCenter+info.WindowWidth/2):
                    output_img[i,j] = max_pixel_intensity
                else:
                    output_img[i,j] = (max_pixel_intensity/info.WindowWidth)*(new_img[i,j] + info.WindowWidth/2-info.WindowCenter)
    output_img = np.uint8(output_img)
    
    """
    info = pydicom.dcmread(filePath)
    img = info.pixel_array
    
    # Initialize variables for conversion to uint8
    output_img = np.zeros_like(img)
    new_img = np.zeros_like(img)
    max_pixel_intensity = 255
    
    # Create new array for rescaled image
    new_img = img*info.RescaleSlope+info.RescaleIntercept
    
    # Create mask for pixels below and above threshold
    mask_below = new_img < (info.WindowCenter - info.WindowWidth/2)
    mask_above = new_img > (info.WindowCenter + info.WindowWidth/2)
    
    # Apply conditions to create output image
    output_img[mask_below] = 0
    output_img[mask_above] = max_pixel_intensity
    output_img = np.where(mask_below, 0, np.where(mask_above, max_pixel_intensity,(max_pixel_intensity /info.WindowWidth) * (new_img + info.WindowWidth / 2 - info.WindowCenter)))
    output_img = np.uint8(output_img)
    
    # Apply harsh mask then a smooth mask
    mask_1 = pct_brainMask_noEyes(output_img, 0, ub, dsize)
    output_img[~mask_1] = 0
    mask_2 = pct_brainMask_noEyes(output_img, 0, ub, 4)
    output_img[~mask_2] = 0
    
    # Resize to 256x256
    output_img = cv2.resize(output_img, (256,256))
    
    return output_img

def pct_brainMask_noEyes(im, lb, ub, dsize):
    """
    Adapted from Ruogu Fang's PCT toolbox.
    "Finds the brain mask on the given image by eliminating negative values and
    values exceeding the upper limit. Additionally, this function removes eyes
    from CT scans."
    
        IM (arr)    - Input image [Y x X]
        LB (int)    - Lower bound
        UB (int)    - Upper bound
        DSIZE (int) - Disk radius for morphological closing
    """
    # Create binary mask
    bin_mask = np.logical_and(lb < im, im <= ub)
    
    # Connected component analysis
    labeled_mask, num_features = label(bin_mask)
    
    # Structure element
    str_element = generate_binary_structure(2, dsize)
    
    # Morphological operations
    mask = binary_closing(bin_mask, structure=str_element)
    mask = binary_opening(mask, structure=str_element)
    str_element = generate_binary_structure(2,9)
    mask = binary_opening(mask, structure=str_element)
    
    # Connected component analysis on the updated mask
    labeled_mask, num_features = label(mask)
    
    # Find the largest connected component
    sizes = np.bincount(labeled_mask.ravel())
    largest_label = np.argmax(sizes[1:]) + 1
    new_mask = (labeled_mask == largest_label)
    
    try:
        # Attempt to perform imclose
        new_mask = binary_closing(new_mask, structure=str_element)
    except:
        pass
    
    return mask

# Set the input folders
deidPath = r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\ct_deidentified"
fstrokePath = r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\fstroke_output"
partitionPath = r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\partition_py"




"""
Above: Setup the input folders. Only change these parameters.
Below:  Initialize all variables to be used in slice matching. 
"""

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
exclude_percent = 0.45 # Decimal percentage of how many slices to exclude from top and bottom

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
        
    # Convert the z-coord keys into a usable matrix using list then array fx.
    NCCT_zs = list(NCCT_zcoords.keys())
    CTP_zs = list(CTP_zcoords.keys())
    NCCT_zs = np.array(NCCT_zs)
    NCCT_zs_sorted = sorted(NCCT_zs)
    CTP_zs = np.array(CTP_zs)
    slice_num = 1
    
    """
    Given a list of coordinates for the NCCT and CTP slices, we start slice
    matching NCCT and CTP. We exclude the first and last N slices from exclude
    slice variable. Each NCCT slice in the non-RAPID data have large deviations
    from each slice (5-15mm gap) so we process every non-excluded slice.
    """
    if len(NCCT_zcoords) > 100:
        step_size = 4
    else:
        step_size = 1
    cutoff = round(len(NCCT_zcoords)*exclude_percent)
    for jj in range(cutoff, len(NCCT_zcoords)-cutoff, step_size):
        
        # Grab ONE NCCT z-coordinate
        NCCT_z = NCCT_zs[jj]
        
        # Grab ONE corresponding CTP z-coordinate
        # !- Pass if we cannot find a corresponding CTP slice
        CTP_abs_value = np.min(np.abs(CTP_zs-NCCT_z)) # Find the value of the smallest absolute difference
        CTP_abs_index = np.argmin(np.abs(CTP_zs-NCCT_z)) # Find the index of the smallest absolute difference
        if CTP_abs_value >= match_threshold: # Next slice if we cannot find a corresponding CTP coordinate
            continue
        CTP_z = CTP_zs[CTP_abs_index]
        correspondingCTPnumber = CTP_zcoords[CTP_z]
        
        # Grab TWO offset NCCT slices
        # !- NCCT slices are sometimes so far apart we just grab the above and below slice.
        idx = NCCT_zs_sorted.index(NCCT_z)
        above = NCCT_zs_sorted[idx+1]
        below = NCCT_zs_sorted[idx-1]
        
        # Get images using the z-coordinates. Access from zcoord dictionary
        NCCT_img_base_path = NCCT_zcoords[NCCT_z]
        NCCT_img_base = process_NCCT(NCCT_img_base_path, ub, dsize)
        
        # If <20% of the image is non-zero, skip slice
        if np.count_nonzero(NCCT_img_base) / NCCT_img_base.size < 0.2:
            continue
        
        # Process offset slices if base slice is informative
        NCCT_img_above_path = NCCT_zcoords[above]
        NCCT_img_above = process_NCCT(NCCT_img_above_path, ub, dsize)
        NCCT_img_below_path = NCCT_zcoords[below]
        NCCT_img_below = process_NCCT(NCCT_img_below_path, ub, dsize)
        
        # Create a mask for non-zero values based on base slice
        mask = NCCT_img_base != 0
        
        # Apply base slice mask to offset slices and base slice
        NCCT_img_base[~mask] = 0
        NCCT_img_above[~mask] = 0
        NCCT_img_below[~mask] = 0
        
        # Concatenate base and offset slices to create pseudo-3D image
        NCCT_img = np.stack([NCCT_img_below, NCCT_img_base, NCCT_img_above], axis=2)
        
        NCCT_img = np.interp(NCCT_img, (np.min(NCCT_img), np.max(NCCT_img)), [0,1])
        
        try:
            MTT_img = process_CTP(fstrokePath, subject, correspondingCTPnumber, mask, 'mtt')
            TTP_img = process_CTP(fstrokePath, subject, correspondingCTPnumber, mask, 'ttp')
            CBF_img = process_CTP(fstrokePath, subject, correspondingCTPnumber, mask, 'cbf')
            CBV_img = process_CTP(fstrokePath, subject, correspondingCTPnumber, mask, 'cbv')
        except:
            continue
        
        # Concatenate NCCT and all CTP slices
        final_img = np.hstack([NCCT_img, MTT_img, TTP_img, CBF_img, CBV_img])
        plt.imshow(final_img)
        plt.show()
        #filename = os.path.join(partitionPath,subject+'_'+str(jj)+'.png')
        filename = os.path.join(partitionPath,subject+'cliplimit_10.png')
        plt.imsave(filename,final_img)
        
        
        
        
        
        
        
        
        