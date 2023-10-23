% function [] = matchISLES2018(inputPath,partitionPath)
%% Match ISLES2018 NCCT and Perfusion Map Slices
% This is the main function for matching NCCT and perfusion maps from the
% ISLES2018 Ischemic Stroke Lesion Segmentation Challenge
% (http://www.isles-challenge.org/ISLES2018/). This code expects the
% unzipped TRAINING and TESTING data to be in inputPath.


% NOTES
% CT 256x256 int32 (max3071) % Looks best with [0 100]
% CBF 256x256x8 uint16 (max6338)
% CBV 256x256x8 uint16 (max742)
% MTT 256x256x8 double (max40)
% Tmax 256x256x8 double (max40)

% ct = niftiread('C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\isles_deid\TRAINING\case_1\SMIR.Brain.XX.O.CT.345562\SMIR.Brain.XX.O.CT.345562.nii');
% cbf = niftiread('C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\isles_deid\TRAINING\case_1\SMIR.Brain.XX.O.CT_CBF.345563\SMIR.Brain.XX.O.CT_CBF.345563.nii');
% cbv = niftiread('C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\isles_deid\TRAINING\case_1\SMIR.Brain.XX.O.CT_CBV.345564\SMIR.Brain.XX.O.CT_CBV.345564.nii');
% mtt = niftiread('C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\isles_deid\TRAINING\case_1\SMIR.Brain.XX.O.CT_MTT.345565\SMIR.Brain.XX.O.CT_MTT.345565.nii');
% ttp = niftiread('C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\isles_deid\TRAINING\case_1\SMIR.Brain.XX.O.CT_Tmax.345567\SMIR.Brain.XX.O.CT_Tmax.345567.nii');
% 
% fprintf("CT")
% 
% ct = uint8(ct);
% for i = 1:8
%     subplot(2,4,i)
%     imshow(imrotate(ct(:,:,i),90),[0 100])
% end

clc;clear;
% Input path MUST contain the unzipped TRAINING and TESTING folders.
inputPath = 'C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\isles_deid';

% Training Loop - hardcoded to the downloaded data for ease
for i = 1:94
    % Read case number in
    caseFile = strcat('case_',num2str(i));
    
    % Set filepath for case
    baseFolder = fullfile(inputPath,'TRAINING',caseFile);
    
    % Get directory list
    % - In order, CT, DWI, CBF, CBV, MTT, Tmax, OT
    baseDir = dir(baseFolder);

    % Remove .and ..
    baseDir(1:2) = [];

    % Read in images
    ct = niftiread(fullfile(baseDir(1).folder,baseDir(1).name,strcat(baseDir(1).name,'.nii')));
    cbf = niftiread(fullfile(baseDir(3).folder,baseDir(3).name,strcat(baseDir(3).name,'.nii')));
    cbv = niftiread(fullfile(baseDir(4).folder,baseDir(4).name,strcat(baseDir(4).name,'.nii')));
    mtt = niftiread(fullfile(baseDir(5).folder,baseDir(5).name,strcat(baseDir(5).name,'.nii')));
    tmax = niftiread(fullfile(baseDir(6).folder,baseDir(6).name,strcat(baseDir(6).name,'.nii')));

    % CT looks best with 100
    % CBF looks best with 1000
    % CBV looks best with 100
    for j = 1:8
        subplot(2,4,j)
        imshow(imrotate(cbv(:,:,j),90),[0 100])
    end
end


% end