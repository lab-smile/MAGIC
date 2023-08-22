## [0.0.2] - 2023-08-22
### Added
- New `legacy` folder will now contain scripts and files that are no longer used.
- New `misc` folder will contain non-script files including .csv and .xlsx files.

### Changed
- `applyImageDenoising.m` Moved from processing to eval.
- `calculate_dice.m` Moved from toolbox/utilities to toolbox/isles.
- All .csv and .xlsx files found in utilities moved to misc folder.

### Deprecated
- `applyaugs.m` Moved to legacy.
- `applyDataAugs.m` Moved to legacy.
- `convertDatasetToGray.m` Moved to legacy.
- `natsort.m` Moved to legacy.
- `natsortfiles.m` Moved to legacy.
- `org_wo_deident_parallel.m` Moved to legacy.
- `Rainbow_CBP.mat` Moved to legacy.
- `reorganize_files.m` Moved to legacy.
- `rgb2v_iterative_deepending.m` Moved to legacy.
- All `di_...` deidentification files are moved to legacy.



## [0.0.1] - 2023-08-22
### Added
- `fixStudy.m` Now combines multiple series folders and removes unnecessary number extensions from filenames (brain.23 > brain)
- `getmetrics.ipynb` New .yaml file
- `processing.sh` Handles processing file on HiPerGator.
- `run_processing.m` Handles all processing files at once. Runs `findSliceMatch_RAPID.m`, `splitData.m`, and `newp2pdataset.m`.
- `splitData.m` Checks if partitioning already completed and skips if necessary.
- Added comments and descriptions to `generated_combined_fig.m`
- Added comments and descriptions to `generate_fake_real_folder.m`

### Changed
- `findSliceMatch_RAPID.m` Updated the printing from subject processing.
- `findSliceMatch_RAPID.m` Now is a function called from `run_processing.m`.
- `getmetrics.ipynb` Uses update libraries. Adjustments are below.
- `getmetrics.ipynb` Updated SSIM from skimage. skimage.measure.compare_ssim --> skimage.metrics.structural_similarity.
- `getmetrics.ipynb` Updated MSE from skimage. skimage.measure.compare_mse --> skimage.metrics.mean_squared_error
- `newp2pdataset.m` Now is a function called from `run_processing.m`.
- `pytorch_pix2pix_test.py` Now appends "_results" to dataset name.
- `splitData.m` Now is a function called from `run_processing.m`.

### Removed
- `generated_combined_fig.m` Removed handel
- `generate_fake_real_folder.m` No longer displays figure for each saved image.

### Fixed
- `fixStudy.m` Resolved an issue where there is a slight difference, "WO-" and "WO_", between two similar study folders. Added a new condition for comparison for CTA folder.
- `fixSeries.m` Adjusted print confirming no issues were found.
- `pytorch_pix2pix_test.py` Replaced os.mkdirs with os.makedirs to handle intermediate directory creation.



## [0.0.0] - 2023-05-26
### Added
- New function `fixStudy.m' to fix directories from DICOM-deidentification. Combines multiple study folders.
- New function `splitData.m` splits the subjects using hold out with validation. Multiple images are stratified.
- Added comments and descriptions to `findSliceMatch_RAPID.m`.
- Added comments and descriptions to `newp2pdataset.m`

### Changed
- Renamed some variable names in `findSliceMatch_RAPID.m` to be more intuitive.
- Any references to the utilities now have relative pathing instead of absolute.

### Fixed
- Re-added missing local function "getCorrectImage" to `findSliceMatch_RAPID.m`.