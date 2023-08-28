## [0.0.2] - 2023-08-22
### Added
- New `legacy` folder will now contain scripts and files that are no longer used.
- New `misc` folder will contain non-script files including .csv and .xlsx files.
- `pytorch_pix2pix.py` Now has tqdm to track training progress.
- `pytorch_pix2pix.py` Now has extensive comments and section numbers.
- `pytorch_pix2pix_test.py` Now checks to make sure batch size is less than the test loader size.

### Changed
- `generate_fake_real_folder.m` Reads .png instead of .bmp
- `findSliceMatch_RAPID.m` Saves .png instead of .bmp
- `findSliceMatch_RAPID.m` A flag system using empty .txt files is now used to track progress, instead of checking for multiple instances of partitioned data within each modality.
- `newp2pdataset.m` Reads .png instead of .bmp
- `applyImageDenoising.m` Moved from processing to eval.
- `calculate_dice.m` Moved from toolbox/utilities to toolbox/isles.
- `pytorch_pix2pix.py` Adjusted multiple argument names and default values.
    - `--ngf` Added help description
    - `--ndf` Added help description
    - `--model_name` New argument to handle model name instead of using `--dataset`.
    - `--num_workers` 2 --> 1
    - `--save_fig_freq` 5 --> 10
    - `--test_subfolder` --> `--val_subfolder`
    - `--test_batch_size` --> `--val_batch_size`
- `pytorch_pix2pix_test.py` Adjusted default values and requirements.
    - `--batch_size` 16 --> 1
    - `--dataset`, `--model_path`, and `--save_root` are now required.
- All .csv and .xlsx files found in utilities moved to misc folder.
- Renamed readme files.
    - `ReadMe_GPU version.md` --> `README_GPU.md`
    - `README_withDocker.md` --> `README_Docker.md`
    - `PrivateREADME.md --> README_Private.md`
- `README.md` Updated and reorganized contents.

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
- `README_withoutHPG.md` Moved to misc. Provides same information in `README.md`

### Fixed
- `fixStudy.m` Resolved an issue where merging was attempted on the completed flag folder.
- `fixSeries.m` Resolved an issue where merging was attempted on the completed flag folder.
- `findSliceMatch_RAPID.m` Resolved an issue where the index for NCCT slice is exceeded.
- `findSliceMatch_RAPID.m` Resolved an issue where the index for NCCT slice is undercut.
- `findSliceMatch_RAPID.m` Resolved an issue with selecting from multiple NCCT modalities. The NCCT keyword is prioritized first, then other filenames, and lastly summary files.
- `pytorch_pix2pix.py` Resolved an issue which could not handle relative pathing.


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