%% Generate visual comparison between real and generated maps
% The current use of this code is to combine the source perfusion maps and
% the generated perfusion maps from MAGIC. This requires the paired dataset
% from createPairedDataset.m.
% 
%   Garrett Fullerton 10/18/2020
%   Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%   Biomedical Engineering
% 
%----------------------------------------
% Last Updated: 8/28/2023 by KS
% 
% 08/28/2023 by KS
% - Changed script name from `generate_combined_fig.m` to
% `generateSliceComparison.m`.
% - Added comments and description.
% - Changed input to fake/real folder
% - Changed output to consist of 
% 
%% Adjustable Variables
% #########################################
close all; clear; clc;
pairedPath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\dataset_paired';
evalPath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\dataset_eval';
% #########################################
% Detect current filename? Expected png for a bit.

% Setup file paths
fake_folder = fullfile(pairedPath,'fake_images');
real_folder = fullfile(pairedPath,'real_images');
ncct_folder = fullfile(real_folder,'NCCT');
output_folder = fullfile(evalPath,'slice');

% Iterate through each NCCT slice
if ~exist(output_folder,'dir'),mkdir(output_folder);end
ncct_files = dir(ncct_folder);
for i = 1:length(ncct_files)
    if strcmp(ncct_files(i).name(1),'.'),continue;end % Skip . and ..
    
    ncct_img = imread(fullfile(ncct_folder,ncct_files(i).name)); % Load NCCT image
    ncct_img(:,:,2) = ncct_img(:,:,1);
    ncct_img(:,:,3) = ncct_img(:,:,1);
    
    % Used to try/catch
    fake_name = strrep(ncct_files(i).name,'.png','_output.png'); % Follow generated image file name
    real_name = ncct_files(i).name;
    
    % Concatenate CBV, CBF, MTT, and TTP for real and fake images
    cbv_img_fake = imread(fullfile(fake_folder,'CBV',real_name));
    cbf_img_fake = imread(fullfile(fake_folder,'CBF',real_name));
    mtt_img_fake = imread(fullfile(fake_folder,'MTT',real_name));
    ttp_img_fake = imread(fullfile(fake_folder,'TTP',real_name));
    
    cbv_img_real = imread(fullfile(real_folder,'CBV',real_name));
    cbf_img_real = imread(fullfile(real_folder,'CBF',real_name));
    mtt_img_real = imread(fullfile(real_folder,'MTT',real_name));
    ttp_img_real = imread(fullfile(real_folder,'TTP',real_name));
    
    fake_img = cat(2,cbv_img_fake,cbf_img_fake,mtt_img_fake,ttp_img_fake);
    real_img = cat(2,cbv_img_real,cbf_img_real,mtt_img_real,ttp_img_real);

    % Create slice image (NCCT--Real--Fake)
    [row,~,dim] = size(fake_img);
    white_img = uint8(ones(row,round(row/3),dim))*0;
    img_final = cat(2,ncct_img,white_img,real_img,white_img,fake_img);
    
    imwrite(img_final,fullfile(output_folder,ncct_files(i).name));
    fprintf('done with %s\n',ncct_files(i).name);
end
% end
disp('all done');
% load handel; sound(y, Fs);
