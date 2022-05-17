

# Description:
    The only file which should be run is "generate_numeric.m". This file will find the UQI, SSIM, PSNR, and RMSE of the synthesized and ground truth
    CTP images at the infarct core and ischemic penumbra regions as found
    in the CBF Mismatch of the ground truth CTP. Images which do not have
    ischemic or infarct core will not affect the metrics. 

# Comments:
   The option to save the comparison of CBF, CBV, TTP, and MTT at the
   bounding boxes for the regions of interests is given. 

# Inputs:
##   realPath: 
the path to the ground truth CTP images. Expected format is a
  single BMP file with 256x256 images of each modality with the following
   ordering from left to right: NCCT->MTT->TTP->CBV->CBF. Test set feed
   into model

##   synPath: 
the path to the synthesized CTP images. Expected format is a
   single PNG file with 256x256 images of each modality with the following
   ordering from left to right: MTT->TTP->CBV->CBF. Raw output of the
   model.

##   rapidPath: 
the path to the rapid data for the patients. This code
   expects that each patient has rapid data and that patients can be found
   using the mapping in the utility folder. This mapping was used when
   going from original folder names to patient names.

##   save_path: 
If you wish to save figures, the desination folder

##   save_figs: 
0 or 1 to identify whether to save figures or not. 0 does
   not and 1 does.

# Output:
   A table with the SSIM, RMSE, UQI, and PSNR where the first row
   corresponds to tissue at risk region and the second row to infarct core
   region. The columns from left to right correspond to MTT -> TTP -> CBV
   -> CBF for each of the metrics.
