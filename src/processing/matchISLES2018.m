% function [] = matchISLES2018(inputPath,partitionPath)
%% Match ISLES2018 NCCT and Perfusion Map Slices
% This is the main function for matching NCCT and perfusion maps from the
% ISLES2018 Ischemic Stroke Lesion Segmentation Challenge
% (http://www.isles-challenge.org/ISLES2018/). This code expects the
% unzipped TRAINING and TESTING data to be in inputPath. Pathing is
% hardcoded as this is an established dataset.
% 
% All NCCT images are saved as 256x256x3 uint8, while perfusion map images
% are saved as 256x256 uint8.
% 
% The raw data from ISLES2018 has the following properties excluding DWI.
% - All images are 256x256 with different number of slices.
% - Cases have 2, 4, 8, 16, or 22 slices.
% - NCCT is int32, CBF and CBV are uint16, and MTT and Tmax are double.
% - Each image has a different ideal display range using imshow.
% 
%   Kyle See 10/24/2023
%   Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%   Biomedical Engineering
%   
%   Input:
%       inputPath      - Path to source folder containing unzipped TRAINING
%                        and TESTING data from ISLES2018.
%       partitionPath  - Path to output folder to store partitioned data.
% 
%----------------------------------------
% Last Updated: 10/24/2023 by KS

%% Adjustable Variables
%#########################################
clc; clear; close all; warning off;
% Input path MUST contain the unzipped TRAINING and TESTING folders.
inputPath = 'C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\isles_deid';
partitionPath = 'C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\isles_partition';
%#########################################

%% Initialization
fprintf("Starting...matchISLES2018.m\n")
fprintf("------------------------------------------------------------------\n")

% Create output directories
rCBVPath = fullfile(partitionPath, 'rCBV');
TTPPath = fullfile(partitionPath, 'TTP');
rCBFPath = fullfile(partitionPath,'rCBF');
MTTPath = fullfile(partitionPath, 'MTT');
NCCTsavePath = fullfile(partitionPath, 'NCCT');
if ~exist(fullfile(partitionPath),'dir'), mkdir(fullfile(partitionPath)); end
if ~exist(rCBVPath,'dir'), mkdir(rCBVPath); end
if ~exist(TTPPath,'dir'), mkdir(TTPPath); end
if ~exist(rCBFPath,'dir'), mkdir(rCBFPath); end
if ~exist(MTTPath,'dir'), mkdir(MTTPath); end
if ~exist(NCCTsavePath,'dir'), mkdir(NCCTsavePath); end

% % Training Loop - hardcoded to the downloaded data for ease
% for i = 1:94
%     % Read case number in
%     caseFile = strcat('case_',num2str(i));
% 
%     % Set filepath for case
%     baseFolder = fullfile(inputPath,'TRAINING',caseFile);
% 
%     % Get directory list
%     % - In order, CT, DWI, CBF, CBV, MTT, Tmax, OT
%     baseDir = dir(baseFolder);
% 
%     % Remove .and ..
%     baseDir(1:2) = [];
% 
%     % Read in images based on positions
%     ct = niftiread(fullfile(baseDir(1).folder,baseDir(1).name,strcat(baseDir(1).name,'.nii')));
%     cbf = niftiread(fullfile(baseDir(3).folder,baseDir(3).name,strcat(baseDir(3).name,'.nii')));
%     cbv = niftiread(fullfile(baseDir(4).folder,baseDir(4).name,strcat(baseDir(4).name,'.nii')));
%     mtt = niftiread(fullfile(baseDir(5).folder,baseDir(5).name,strcat(baseDir(5).name,'.nii')));
%     tmax = niftiread(fullfile(baseDir(6).folder,baseDir(6).name,strcat(baseDir(6).name,'.nii')));
% 
%     % Cycle through all of the slices
%     num_slices = size(cbf,3);
%     for j = 1:num_slices
%         if i < 10
%             saveName = strcat('10000',num2str(i),'_0',num2str(j),'.png');
%         else
%             saveName = strcat('1000',num2str(i),'_',num2str(j),'.png');
%         end
% 
%         % Copy image twice to simulate pseudo-RGB input
%         savePathNCCT = fullfile(partitionPath,'NCCT',saveName);
%         sliceNCCT = imrotate(ct(:,:,j),90);
%         sliceNCCT(:,:,2) = imrotate(ct(:,:,j),90);
%         sliceNCCT(:,:,3) = imrotate(ct(:,:,j),90);
%         sliceNCCT = uint8(sliceNCCT);
%         imwrite(sliceNCCT,savePathNCCT)
% 
%         savePathCBF = fullfile(partitionPath,'rCBF',saveName);
%         sliceCBF = uint8(imrotate(cbf(:,:,j),90));
%         sliceCBF = imadjust(sliceCBF);
%         imwrite(sliceCBF,savePathCBF)
% 
%         savePathCBV = fullfile(partitionPath,'rCBV',saveName);
%         sliceCBV = uint8(imrotate(cbv(:,:,j),90));
%         sliceCBV = imadjust(sliceCBV);
%         imwrite(sliceCBV,savePathCBV)
% 
%         savePathMTT = fullfile(partitionPath,'MTT',saveName);
%         sliceMTT = uint8(imrotate(mtt(:,:,j),90));
%         sliceMTT = imadjust(sliceMTT);
%         imwrite(sliceMTT,savePathMTT)
% 
%         savePathTTP = fullfile(partitionPath,'TTP',saveName);
%         sliceTTP = uint8(imrotate(tmax(:,:,j),90));
%         sliceTTP = imadjust(sliceTTP);
%         imwrite(sliceTTP,savePathTTP)
%     end
% end

% Testing Loop - hardcoded to the downloaded data for ease
for i = 1:62 % 63 is a file called .DS_Store
    % Read case number in
    caseFile = strcat('case_',num2str(i));
    
    % Set filepath for case
    baseFolder = fullfile(inputPath,'TESTING',caseFile);
    
    % Get directory list
    % - In order, CT, DWI, CBF, CBV, MTT, Tmax, OT
    baseDir = dir(baseFolder);

    % Remove .and ..
    baseDir(1:2) = [];

    % Read in images based on positions
    ct = niftiread(fullfile(baseDir(1).folder,baseDir(1).name,strcat(baseDir(1).name,'.nii')));
    cbf = niftiread(fullfile(baseDir(3).folder,baseDir(3).name,strcat(baseDir(3).name,'.nii')));
    cbv = niftiread(fullfile(baseDir(4).folder,baseDir(4).name,strcat(baseDir(4).name,'.nii')));
    mtt = niftiread(fullfile(baseDir(5).folder,baseDir(5).name,strcat(baseDir(5).name,'.nii')));
    tmax = niftiread(fullfile(baseDir(6).folder,baseDir(6).name,strcat(baseDir(6).name,'.nii')));

    % Cycle through all of the slices
    num_slices = size(cbf,3);
    for j = 1:num_slices
        if i < 10
            saveName = strcat('20000',num2str(i),'_0',num2str(j),'.png');
        else
            saveName = strcat('2000',num2str(i),'_',num2str(j),'.png');
        end
        
        % Copy image twice to simulate pseudo-RGB input
        savePathNCCT = fullfile(partitionPath,'NCCT',saveName);
        sliceNCCT = imrotate(ct(:,:,j),90);
        sliceNCCT(:,:,2) = imrotate(ct(:,:,j),90);
        sliceNCCT(:,:,3) = imrotate(ct(:,:,j),90);
        sliceNCCT = uint8(sliceNCCT);
        imwrite(sliceNCCT,savePathNCCT)
        
        savePathCBF = fullfile(partitionPath,'rCBF',saveName);
        sliceCBF = uint8(imrotate(cbf(:,:,j),90));
        sliceCBF = imadjust(sliceCBF);
        imwrite(sliceCBF,savePathCBF)
        
        savePathCBV = fullfile(partitionPath,'rCBV',saveName);
        sliceCBV = uint8(imrotate(cbv(:,:,j),90));
        sliceCBV = imadjust(sliceCBV);
        imwrite(sliceCBV,savePathCBV)
        
        savePathMTT = fullfile(partitionPath,'MTT',saveName);
        sliceMTT = uint8(imrotate(mtt(:,:,j),90));
        sliceMTT = imadjust(sliceMTT);
        imwrite(sliceMTT,savePathMTT)
        
        savePathTTP = fullfile(partitionPath,'TTP',saveName);
        sliceTTP = uint8(imrotate(tmax(:,:,j),90));
        sliceTTP = imadjust(sliceTTP);
        imwrite(sliceTTP,savePathTTP)
    end
end


% end
