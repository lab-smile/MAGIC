% function [] = matchNCCTandFSTROKE(deidPath,fstrokePath,partitionPath)
%% Match NCCT and FSTROKE Perfusion Map Slices
% This is the main function for matching NCCT and FSTROKE perfusion map
% slices. This function requires that the dataset contains NCCT and
% perfusion map data. The steps performed in this function include:
% 
%   - Load all NCCT and perfusion map slices
%   - Match slices between NCCT and perfusion map every 10 slices
%   - Create pseudo-RGB NCCT combining two offset(+/-4mm) slices
% 
% Expect NCCT to have 1.0mm resolution (SliceThickness) with 160 slices.
% Each .dcm file contains a 512x512 slice. Slices are saved as 256x256x3
% uint8.
% 
% Expect CTP perfusion maps to be from FSTROKE with 0.5mm resolution with
% 320 slices. Each .nii.gz file contains 512x512x320 single.
% 
%   Kyle See 10/16/2023
%   Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%   Biomedical Engineering
% 
%   Input:
%       deidPath     - Path to source folder containing deid subjects (NCCT).
%       fstrokePath  - Path to source folder containing fstroke outputs.
%       outputPath   - Path to output folder to store partitioned data.
% 
%----------------------------------------
% Last Updated: 10/16/2023 by KS

%% Adjustable Variables
%#########################################
clc; clear; close all; warning off;
% Deid folders must follow the order: Subject -> Study -> Session -> Image
% Fstroke folders must contain 
deidPath = 'C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\test_deid_fstroke';
fstrokePath = 'C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\test_fstroke';
partitionPath = 'C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\test_partition';
%#########################################

%% Initialization 
% Add utilities
% - rgb2values.m
% - convert_dicom_to_uint8.m
% - apply_ncct_mask.m
% - fix_series.m
% - fix_study.m
% - parsave.m
% - pct_brainMask_noEyes.m
% - rapid_modalities.mat
addpath('../toolbox/utilities')

fprintf("Starting...matchNCCTandFSTROKE.m\n")
fprintf("------------------------------------------------------------------\n")

% Fix any issues with study or series folders
fix_study(deidPath)
fix_series(deidPath)

% Load the color map?
load('../toolbox/roi_performance/RAPID_U.mat','Rapid_U')

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

NCCT_slice_offset = 4; % How many offset slices from main slice
offset_range = NCCT_slice_offset*2+1; % Range for 1 NCCT slice
dsize = 7; % Disk radius for morphological closing, used in Fang's PCT function (originally 7)
ub = 200; % Upperbound, used in Fang's PCT function

% Checkpoint files to skip subjects
flagPath = fullfile(deidPath,'completed');
if ~exist(flagPath,'dir'), mkdir(flagPath); end
subjects = dir(deidPath);   % Directory list of input folders
subjects(end) = [];         % Get rid of "completed" folder
subjects(1:2) = [];         % Get rid of . and ..

fstroke = dir(fstrokePath); % Directory list of fstroke folders
fstroke(1:2) = [];

%% Slice matching NCCT and FSTROKE
% Loop through all subjects from deidPath (skips hidden)
for i = 1:length(subjects)
    % Grab subject name
    subject = subjects(i);
    subject_name = subject.name;
    
    % 

    % Skip file if necessary
    flagFile = fullfile(flagPath,[subject_name,'.txt']);
    if exist(flagFile,'file')
        fprintf("> Subject %s already processed\n",subject_name)
        continue;
    end

    % Skip file if it is not a study folder
    [~,~,ext] = fileparts(fullfile(subject.folder,subject_name)); % Get extension
    if strcmp(ext,'.csv') || strcmp(ext,'.xlsx'), continue; end   % Skip if not a study folder
    if strcmp(subject_name(1),'.'), continue; end                 % Skip if not a study folder
    fprintf('Processing subject %s\n',subject_name)

    % Study folder expected as 3rd position behind . and .. and in front of .csv and .xlsx
    study_name = dir(fullfile(subject.folder,subject.name));
    study_name = study_name(3);
    series_all = dir(fullfile(study_name.folder, study_name.name));
    series_names = {series_all.name}; % Grab all series names

    % Indexing, looking for the NCCT series using keywords
    NCCT_idx = contains(series_names,'without','IgnoreCase',true);
    NCCT_idx = or(NCCT_idx,contains(series_names,'W-O','IgnoreCase',true));
    NCCT_idx = or(NCCT_idx,contains(series_names,'NCCT','IgnoreCase',true));
    NCCT_idx = or(NCCT_idx,contains(series_names,'NON-CON','IgnoreCase',true));
    NCCT_idx = or(NCCT_idx,contains(series_names,'NON_CON','IgnoreCase',true));
    NCCT_idx = and(NCCT_idx,~contains(series_names,'bone','IgnoreCase',true));
    NCCT_idx = and(NCCT_idx,~contains(series_names,'5.0','IgnoreCase',true));

    % Grab ALL files from the NCCT series
    NCCT_series = [];
    if ~any(NCCT_idx) % Cannot find an NCCT series
        fprintf('Cannot locate NCCT series for subject %s.\n',subject.name);
        continue;
    else
        NCCT_series = series_names(NCCT_idx);
        contains_NCCT = contains(NCCT_series, "NCCT");
        index_NCCT = find(contains_NCCT,1);
        if ~isempty(index_NCCT)
            NCCT_series_name = string(NCCT_series(index_NCCT));
        else
            contains_summary = ~contains(NCCT_series, "SUMMARY");
            index_summary = find(contains_summary,1);
            if ~isempty(index_summary)
                NCCT_series_name = string(NCCT_series(index_summary));
            else
                NCCT_series_name = string(NCCT_series(1));
            end
        end
        NCCT_files = dir(fullfile(study_name.folder,study_name.name,NCCT_series_name,'*.dcm'));
    end
 
    % Skip the first 4 and last 4 slices.
    first_slice_loc = NCCT_slice_offset+1;    
    last_slice_loc = first_slice_loc + offset_range * floor((length(NCCT_files)-first_slice_loc) / offset_range);
    slices = linspace(first_slice_loc, last_slice_loc,(last_slice_loc-first_slice_loc)/offset_range+1);
    slices = slices(5:end-4);
    
    % Loop through main slices given offset [-offset | main | +offset]
    for jj = 1:length(slices)
        ii = slices(jj);

        % Process NCCT slice given img and info. Repeat with offset slices
        NCCT_file = NCCT_files(ii);
        NCCT_img = processNCCT(NCCT_file, ub, dsize);
        
        NCCTplus_file = NCCT_files(ii+NCCT_slice_offset);
        NCCTplus_img = processNCCT(NCCTplus_file, ub, dsize);

        NCCTminus_file = NCCT_files(ii-NCCT_slice_offset);
        NCCTminus_img = processNCCT(NCCTminus_file, ub, dsize);

        % Re-apply main mask to offset slices
        mask = NCCT_img ~= 0;
        NCCT_img(~mask)= 0;
        NCCTplus_img(~mask)= 0;
        NCCTminus_img(~mask)= 0;
        
        % Concatenate all 3 slices together
        NCCT_img = cat(3, NCCTminus_img, NCCT_img, NCCTplus_img);

        % Save NCCT image
        saveName = strcat(subject_name,'_',num2str(jj),'.png');
        savePath = fullfile(partitionPath,'NCCT',saveName);
        imwrite(NCCT_img,savePath)
        
        % Convert perfusion map to specific ranges and save appropriately
        % -- CBF: 0-60, CBV: 0-4, MTT: 0-12, TTP: 0-25
        CBF_path = fullfile(fstrokePath,subject_name,'cbf.nii.gz');
        processPerf(CBF_path,partitionPath,subject_name,ii,jj,mask,'cbf')

        CBV_path = fullfile(fstrokePath,subject_name,'cbv.nii.gz');
        processPerf(CBV_path,partitionPath,subject_name,ii,jj,mask,'cbv')

        MTT_path = fullfile(fstrokePath,subject_name,'mtt.nii.gz');
        processPerf(MTT_path,partitionPath,subject_name,ii,jj,mask,'mtt')

        TTP_path = fullfile(fstrokePath,subject_name,'tmax.nii.gz');
        processPerf(TTP_path,partitionPath,subject_name,ii,jj,mask,'ttp')
        
    end
    fileID = fopen(flagFile,'w');
    fclose(fileID);
    fprintf('> Finished with subject %s\n',subject_name);
end
fprintf("------------------------------------------------------------------\n")
fprintf("Finished...matchNCCTandFSTROKE.m\n")
fprintf("------------------------------------------------------------------\n")

% end

%% Local Functions
function processPerf(dataPath,partitionPath,subject_name,loc,jj,mask,type)
    % -- Process perfusion map and save based on type --
    % To debug how slices look:
    % imshow(CBV_slice, [0 25])
    % figure; imshow(CBV_slice, [0 25])

    % 
    map = niftiread(dataPath);
    slice = imrotate(map(:,:,loc*2),270);
    slice = uint8(normalize(slice,"range",[0 60]));
    slice = imresize(slice,[256 256]); % Resize after making all changes
    slice(~mask) = 0; % Apply mask
    if type == 'cbf' 
        saveName = strcat(subject_name,'_',num2str(jj),'.png');
        savePath = fullfile(partitionPath,'rCBF',saveName);
        figure('Visible','off')
        imshow(slice,[0 60])
        exportgraphics(gcf,savePath)
        close;
    elseif type == 'cbv'
        saveName = strcat(subject_name,'_',num2str(jj),'.png');
        savePath = fullfile(partitionPath,'rCBV',saveName);
        figure('Visible','off')
        imshow(slice,[0 60])
        exportgraphics(gcf,savePath)
        close;
    elseif type == 'mtt'
        saveName = strcat(subject_name,'_',num2str(jj),'.png');
        savePath = fullfile(partitionPath,'MTT',saveName);
        figure('Visible','off')
        imshow(slice,[0 60])
        exportgraphics(gcf,savePath)
        close;
    elseif type == 'ttp'
        saveName = strcat(subject_name,'_',num2str(jj),'.png');
        savePath = fullfile(partitionPath,'TTP',saveName);
        figure('Visible','off')
        imshow(slice,[0 60])
        exportgraphics(gcf,savePath)
        close;
    else
        fprintf("Perfusion type unrecognized")
    end
    
end

function img = processNCCT(file, ub, dsize)
    % -- Process NCCT using pct tools to mask twice --
    % Read dicom image and metadata
    filepath = fullfile(file.folder, file.name);
    img = dicomread(filepath);
    info = dicominfo(filepath);
    
    % Use metadata to resize and rescale img data
    img = convert_dicom_to_uint8(img,info);
    
    % Apply harsh mask then smooth mask
    mask = pct_brainMask_noEyes(img, 0, ub, dsize);
    img(~mask) = 0;
    mask2 = pct_brainMask_noEyes(img, 0, ub, 4);
    img(~mask2) = 0;
    
    % Resize to 256x256
    img = imresize(img,[256 256]);
end