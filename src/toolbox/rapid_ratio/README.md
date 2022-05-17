# Description:
   The only file which should be run is "generate_ratios.m". This file finds the mismatch ratios as defined in https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2975404/. The mismatch ratio is the ratio of the volume of infarct core to the volume tissue at risk determined by summing the regions of the
   Rapid CBF Mismatch which is an estimate for the infarct core and tissue at risk regions. This is done for every
   patient in datasetPath. The ratios and their corresponding patientID
   are printed to outputFile.

# Comments:
   It is expected that datasetPath is composed of patients with Rapid and
   as such WILL have a CBF mismatch image. If you don't have patients with
   only Rapid, there are scripts under evaluation > RAPID that will
   perform this task on deidentified data and identfied data (the fastest
   runs on deidentified data)
   
   There is an example result file called "mismatch-ratio.xlsx". This was obtained by running generate_ratios('F:\DICOM_RAPID_Organized', 'mismatch-ratios.xlsx') on the SMILE Lab desktop "BME-FAN-2NCPP22.ad.ufl.edu". The data the example results was obtained from included 493 subjects which all had Rapid summaries.

# Inputs:
##   datasetPath : 
path to dataset with patients, importantly, structure of
       the patients within the dataset must follow the structure outputted by
       the deidentified code. This structure is discussed in the main README
       of the github repo.

##   outputFile : 
The name of the file which will contain the table composed
       of patientIDs and their mismatch ratio. Only absolute path names for
       outputFile will be accepted. For best results, verify that the
       extension of outputFile is .xlsx

## Output:
   Table with patientIDs and their corresponding mismatch ratio across the volume calculated from 14
       z-slices. This table will be saved to the location specified in
       outputFile.
