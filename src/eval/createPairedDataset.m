%% Organize test results into fake and real folders
% The current use of this code is to apply modality-specific colormaps,
% denoise the images, and save the outputs per modality. The resulting
% structure is separated into fake (test results) and real (test input)
% folders. Each folder contains each perfusion map modality (MTT, TTP, CBF,
% and CBV). Real folder contains NCCT. The colormap scaling follows:
% 
% - CBF (0-60), CBV (0-4), MTT (0-12), TTP (0-25)
% 
% The results path is expected to be the generated perfusion maps sourced
% from the test partition of your dataset. All evaluation scripts will use
% the output of this code as the base input.
% 
%   Garrett Fullerton 10/18/2020
%   Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%   Biomedical Engineering
% 
%   Input:
%       datasetPath   - Path to source folder containing the dataset.
%       resultsPath   - Path to folder containing generated results.
%       outputPath    - Path to output folder to store separated images.
% 
%----------------------------------------
% Last Updated: 8/17/2023 by KS
% 
% 08/17/2023 by KS
% - Added comments and full description
% - Changed script name from `generate_fake_real_folder.m` to
% `createPairedDataset.m`.
%
%% Adjustable Variables
% #########################################
close all; clear; clc;
inputPath = 'C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\dataset_A2';
resultsPath = 'C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\dataset_A2_L1';
outputPath = 'C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\dataset_A2_L1_output';
% #########################################
% Add utilities
% - apply_image_denoising.m
addpath('../toolbox/utilities')

fprintf("Starting...createPairedDataset.m\n")
fprintf("------------------------------------------------------------------\n")

% Constructing file paths
real_folder = fullfile(inputPath,'test'); % Test input for model training
fake_folder = fullfile(resultsPath,'results');

% Post-processing method for image denoising. Median was used for final results
method = 'median'; 

fprintf("Dataset folder (input): %s\n",real_folder)
fprintf("Results folder (results): %s\n",fake_folder)
fprintf("Output folder: %s\n",outputPath)
fprintf("------------------------------------------------------------------\n")

% Creates output directories
if ~exist(outputPath,'dir'),mkdir(outputPath);end
realsavepath = makeSubfolder(outputPath,'real_images');
fakesavepath = makeSubfolder(outputPath,'fake_images');
realslicepath = makeSubfolder(outputPath,'real_montage');
fakeslicepath = makeSubfolder(outputPath,'fake_montage');

% Prepare colormap
load('Rapid_Colormap.mat');
c_map = Rapid_U;
unit = 256; %img size

% Make subfolders 
fake_img_folder = fullfile(fake_folder);
real_img_folder = fullfile(real_folder);
images = dir(real_img_folder);

fprintf("Processing...%d images\n",size(images,1))

% Loop through each image and separate images. Process each image
% individually and save to modality-specific folder.
for i = 1:length(images)
    % Construct image filenames
    img = images(i);
    imgname_real = img.name;
    if strcmp(imgname_real(1),'.'), continue; end % Skip . and ..
    imgname_fake = strrep(imgname_real,'.png','_output.png'); % Change to result filename
    
    % Read images
    fake_img = imread(fullfile(fake_img_folder,imgname_fake));
    real_img = imread(fullfile(real_img_folder,imgname_real));
    
    % Reads fake image as 4-img montage (mtt, ttp, cbf, cbv)
    % Convert to gray to read different color maps
    mtt_f = rgb2gray(fake_img(:,unit*0+1:unit*1,:));
    ttp_f = rgb2gray(fake_img(:,unit*1+1:unit*2,:));
    rcbf_f = rgb2gray(fake_img(:,unit*2+1:unit*3,:));
    rcbv_f = rgb2gray(fake_img(:,unit*3+1:unit*4,:));
    
    % Method is median
    mtt_f = apply_image_denoising(mtt_f,method);
    ttp_f = apply_image_denoising(ttp_f,method);
    rcbf_f = apply_image_denoising(rcbf_f,method);
    rcbv_f = apply_image_denoising(rcbv_f,method);
    
    % Reads real image as 5-img montage (ncct, mtt, ttp, cbf, cbv)
    ncct_r = real_img(:,unit*0+1:unit*1,2);
    mtt_r = rgb2gray(real_img(:,unit*1+1:unit*2,:));
    ttp_r = rgb2gray(real_img(:,unit*2+1:unit*3,:));
    rcbf_r = rgb2gray(real_img(:,unit*3+1:unit*4,:));
    rcbv_r = rgb2gray(real_img(:,unit*4+1:unit*5,:));

    % Save images using colormaps
    % - Fake images
    saveImageFinal(mtt_f, c_map, imgname_real, fakesavepath, 'MTT');
    saveImageFinal(ttp_f, c_map, imgname_real, fakesavepath, 'TTP');
    saveImageFinal(rcbf_f, c_map, imgname_real, fakesavepath, 'CBF');
    saveImageFinal(rcbv_f, c_map, imgname_real, fakesavepath, 'CBV');
    % - Real images
    saveImageFinal(mtt_r, c_map, imgname_real, realsavepath, 'MTT');
    saveImageFinal(ttp_r, c_map, imgname_real, realsavepath, 'TTP');
    saveImageFinal(rcbf_r, c_map, imgname_real, realsavepath, 'CBF');
    saveImageFinal(rcbv_r, c_map, imgname_real, realsavepath, 'CBV');
    imwrite(ncct_r,fullfile(makeSubfolder(realsavepath,'NCCT'),imgname_real));
    fprintf("Saved %s\n",imgname_real)
end

% Loop through the modality images to re-create the montages for getMetrics
for j = 1:length(images)
    % Get subject ID
    img = images(j);
    imgname = img.name;
    if strcmp(imgname(1),'.'), continue; end % Skip . and ..
    
    % Read all real images
    ncct_r = imread(fullfile(realsavepath,'NCCT',imgname));
    mtt_r = imread(fullfile(realsavepath,'MTT',imgname));
    ttp_r = imread(fullfile(realsavepath,'TTP',imgname));
    cbf_r = imread(fullfile(realsavepath,'CBF',imgname));
    cbv_r = imread(fullfile(realsavepath,'CBV',imgname));
    
    ncct_r(:,:,2) = ncct_r(:,:,1);
    ncct_r(:,:,3) = ncct_r(:,:,1);
    
    slice_r = cat(2,ncct_r,mtt_r,ttp_r,cbf_r,cbv_r);
    savename_r = fullfile(realslicepath,imgname);
    imwrite(slice_r,savename_r)

    % Read all fake images
    mtt_f = imread(fullfile(fakesavepath,'MTT',imgname));
    ttp_f = imread(fullfile(fakesavepath,'TTP',imgname));
    cbf_f = imread(fullfile(fakesavepath,'CBF',imgname));
    cbv_f = imread(fullfile(fakesavepath,'CBV',imgname));
    
    slice_f = cat(2,mtt_f,ttp_f,cbf_f,cbv_f);
    savename_f = fullfile(fakeslicepath,imgname);
    imwrite(slice_f,savename_f)
end

fprintf("Finished...createPairedDataset.m\n")
fprintf("------------------------------------------------------------------\n")

%% Local Functions
function newfilepath = makeSubfolder(savepath,folder_name)
newfilepath = fullfile(savepath,folder_name);
if ~exist(newfilepath,'dir')
    mkdir(newfilepath);
end
end

function saveImageFinal(mtt_f, c_map, imgname_real, savepath, modality)
figure('visible','off'); imshow(mtt_f); colormap(c_map);
f = getframe;
mtt_f_savepath = makeSubfolder(savepath,modality);
savename = fullfile(mtt_f_savepath,imgname_real);
imwrite(f.cdata,savename);
close all;
end
