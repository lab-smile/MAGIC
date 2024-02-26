# -*- coding: utf-8 -*-
"""
@author: kylebsee
"""
import os
import numpy as np
from scipy.ndimage import label, generate_binary_structure, binary_closing, binary_opening, rotate
import nibabel as nib
import cv2
import pydicom
from skimage.transform import resize
import scipy.io # For colormap code
from matplotlib.colors import ListedColormap # For colormap code

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
    
    # - Applies colormap using the .mat file
    #colormap_var = scipy.io.loadmat(r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\rapid_colormap.mat")
    #colormap = colormap_var['Rapid_U']
    #custom_colormap = ListedColormap(colormap)
    
    slice_index = loc
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
   
    #plt.imshow(img_slice, cmap='gray')
    #plt.title(CTPType)
    #plt.show()
    
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