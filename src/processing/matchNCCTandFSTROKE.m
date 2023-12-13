function [] = matchNCCTandFSTROKE(deidPath,fstrokePath,partitionPath)
%% Match NCCT and FSTROKE Perfusion Map Slices
% This is the main function for matching NCCT and FSTROKE perfusion map
% slices. This functions requires that the dataset contains NCCT and
% perfusion map data. Currently works on UFHealth data. The steps follow:
%   - Load all NCCT slices and perfusion map volumes
%   - List all z-locations from each NCCT slice and pull z-locations from
%     original perfusion volume.
%   - Loop through NCCT z-locations and find closest CTP map slice within
%     'match_threshold (mm)'.
%   - For NCCT only, save additional offset slices using
%     'NCCT_slice_offset' above and below selected slice.
%   - NCCT ranges do not exceed the offset range to prevent overlap using
%     'offset_range'.
%   - Slices with only >80% pixel counts are saved. This removes the very
%     top and bottom of the head.
% 
% This should work with NCCT of any resolution. For example, NCCT with
% 1.0mm resolution (SliceThickness) has 160 slices. NCCT with 0.5mm
% resolution (same as CTP) has 320 slices. Each .dcm file contains a
% 512x512 slice along with required metadata. Slices are saved as 256x256x3
% uint8.
% 
% Expect CTP perfusion maps to be from FSTROKE with 0.5mm resolution with
% 320 slices. Each .nii.gz file contains 512x512x320 single. Z-locations
% are taken from ORIGINAL CTP from the deidentified data.
%   - NCCT z-loc are stored in ImagePositionPatient per file.
%   - All CTP z-loc are stored in PerFrameFunctionalGroupsSequence >
%     Item_SLICE# > PlanePositionSequence > Item_1 > ImagePositionPatient.
% 
% Error logs are created in a separate folder outside the parent folder.
% These detail the reason why a subject does not have slices saved.
%   - Does not possess an NCCT series or cannot find one.
%   - Does not possess a CTP series or cannot find one.
%   - There are too many CTP series.
%   - There is an error loading the CTP series.
%   - There are no NCCT coordinates available in the NCCT series.
%   - The metadata "ImagePositionPatient" cannot be found.
%   - The subject does not have an F-Stroke output.
% 
%   Kyle See 10/16/2023
%   Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%   Biomedical Engineering
% 
%   Input:
%       deidPath       - Path to source folder containing deid subjects (NCCT).
%       fstrokePath    - Path to source folder containing fstroke outputs.
%       partitionPath  - Path to output folder to store partitioned data.
% 
%----------------------------------------
% Last Updated: 11/20/2023 by KS
% 
% 11/20/2023 by KS
% - Changed to calculate the z-location instead of matching per slice.

%% Adjustable Variables
%#########################################
% clc; clear; close all; warning off;
% Deid folders must follow the order: Subject -> Study -> Session -> Image
% Fstroke folders must contain 
% deidPath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\test_deid_fstroke';
% fstrokePath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\test_fstroke';
% partitionPath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\test_partition';
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

NCCT_slice_offset = 4; % How many offset slices from main slice (mm)
offset_range = NCCT_slice_offset*2+1; % Range for 1 NCCT slice (mm)
dsize = 7; % Disk radius for morphological closing, used in Fang's PCT function (originally 7)
ub = 200; % Upperbound, used in Fang's PCT function
match_threshold = 2; % Maximum threshold for finding matching Perfusion map slice (mm)

% Checkpoint files to skip subjects
flagPath = fullfile(deidPath,'completed');
if ~exist(flagPath,'dir'), mkdir(flagPath); end
subjects = dir(deidPath);   % Directory list of input folders
subjects(end) = [];         % Get rid of "completed" folder
subjects(1:2) = [];         % Get rid of . and ..

% Save a separate error flag path
[parentFolder,~,~] = fileparts(deidPath);
errorFlagPath = fullfile(parentFolder,'error_flags');
if ~exist(errorFlagPath,'dir'), mkdir(errorFlagPath); end

fstroke = dir(fstrokePath); % Directory list of fstroke folders
fstroke(1:2) = [];

%% Slice matching NCCT and FSTROKE
% Loop through all subjects from deidPath (skips hidden)
for i = 1:length(subjects)
    % Grab subject name
    subject = subjects(i);
    subject_name = subject.name;

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

    % Set up containers (python dict equiv)
    NCCT_zcoords = containers.Map('KeyType','double','ValueType','char');
    CTP_zcoords = containers.Map('KeyType','double','ValueType','char');
    
    %     % Look for the NCCT series using keywords
    %     NCCT_idx = contains(series_names,'without','IgnoreCase',true);
    %     NCCT_idx = or(NCCT_idx,contains(series_names,'W-O','IgnoreCase',true));
    %     NCCT_idx = or(NCCT_idx,contains(series_names,'NCCT','IgnoreCase',true));
    %     NCCT_idx = or(NCCT_idx,contains(series_names,'NON-CON','IgnoreCase',true));
    %     NCCT_idx = or(NCCT_idx,contains(series_names,'NON_CON','IgnoreCase',true));
    %     NCCT_idx = and(NCCT_idx,~contains(series_names,'bone','IgnoreCase',true));
    %     NCCT_idx = and(NCCT_idx,~contains(series_names,'5.0','IgnoreCase',true));
    %     NCCT_idx = and(NCCT_idx,~contains(series_names,'0.5','IgnoreCase',true));
    %     NCCT_idx = and(NCCT_idx,~contains(series_names,'soft_tissue','IgnoreCase',true));

    % Look for the NCCT series using keywords
    NCCT_include = {'without', 'W-O', 'NCCT', 'NON-CON', 'NON_CON'};
    NCCT_exclude = {'bone', '0.5', 'soft_tissue', 'Untitled', 'MIP', 'Stack', 'Summary', 'CTA', 'SUB', 'Dynamic', 'Perfusion', 'Lung', 'Sft', 'Soft'};
    NCCT_idx = false(size(series_names)); % Initialize to include everything
    for kk = 1:length(NCCT_include)
        NCCT_idx = or(NCCT_idx, contains(series_names, NCCT_include{kk}, 'IgnoreCase', true));
    end
    for kk = 1:length(NCCT_exclude)
        NCCT_idx = and(NCCT_idx, ~contains(series_names, NCCT_exclude{kk}, 'IgnoreCase', true));
    end
    
    %     % Look for CTP series using keywords
    %     CTP_idx = contains(series_names,'0.5','IgnoreCase',true);
    %     CTP_idx = or(CTP_idx,contains(series_names,'4D','IgnoreCase',true));
    %     CTP_idx = or(CTP_idx,contains(series_names,'Perfusion','IgnoreCase',true));
    %     CTP_idx = or(CTP_idx,contains(series_names,'Dynamic','IgnoreCase',true));
    %     CTP_idx = or(CTP_idx,contains(series_names,'Head','IgnoreCase',true));
    %     CTP_idx = and(CTP_idx,~contains(series_names,'CTA','IgnoreCase',true));
    %     CTP_idx = and(CTP_idx,~contains(series_names,'Summary','IgnoreCase',true));
    %     CTP_idx = and(CTP_idx,~contains(series_names,'Bone','IgnoreCase',true));
    %     CTP_idx = and(CTP_idx,~contains(series_names,'MIP','IgnoreCase',true));
    %     CTP_idx = and(CTP_idx,~contains(series_names,'1.0','IgnoreCase',true));

    % Look for the CTP series using keywords
    % Old include uses 0.5, 4D, Perfusion, Dynamic, Head
    % Old exclude uses CTA, Summary, Bone, MIP, 1.0
    CTP_include = {'0.5','CBP' ,'4D' ,'Perfusion' ,'Dynamic'};
    CTP_exclude = {'2.0', 'MIP' ,'Untitled' ,'Stack' ,'Summary' ,'CTA' ,'SUB' ,'CTV' ,'Bone' ,'Soft' ,'Maps' ,'Body' ,'Axial' ,'Coronal' ,'Tissue' ,'Soft' ,'Sft' ,'Removed' ,'HCT' ,'Map' ,'With' ,};
    CTP_idx = false(size(series_names)); % Initialize to include everything
    for kk = 1:length(CTP_include)
        CTP_idx = or(CTP_idx, contains(series_names, CTP_include{kk}, 'IgnoreCase', true));
    end
    for kk = 1:length(CTP_exclude)
        CTP_idx = and(CTP_idx, ~contains(series_names, CTP_exclude{kk}, 'IgnoreCase', true));
    end
    
    % Grab ALL files from the NCCT series
    NCCT_series = [];
    if ~any(NCCT_idx) % Cannot find an NCCT series
        fileID = fopen(flagFile,'w');
        fclose(fileID);
        errorFlagFile = fullfile(errorFlagPath,[subject_name,'_missing_NCCT.txt']);
        fid = fopen(errorFlagFile,'w');
        fclose(fid);
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
 
    % Grab any file from CTP series. It doesn't matter which CTP we grab so
    % we grab the file with the largest size. CTP files generally have
    % 50-65MB. Other files tend to have <100KB and one file with 20-25MB.
    CTP_series = [];
    if ~any(CTP_idx) % Cannot find a CTP series
        fileID = fopen(flagFile,'w');
        fclose(fileID);
        errorFlagFile = fullfile(errorFlagPath,[subject_name,'_missing_CTP.txt']);
        fid = fopen(errorFlagFile,'w');
        fclose(fid);
        fprintf('Cannot locate CTP series for subject %s.\n',subject.name);
        continue;
    else
        CTP_series = series_names(CTP_idx);
        if length(CTP_series) > 1 || length(CTP_series) == 0
            fileID = fopen(flagFile,'w');
            fclose(fileID);
            errorFlagFile = fullfile(errorFlagPath,[subject_name,'_multiple_CTP.txt']);
            fid = fopen(errorFlagFile,'w');
            fclose(fid);
            fprintf('More than one CTP series found for %s.\n',subject_name);
            continue;
        else
            try
                CTP_series_name = string(CTP_series(1));
                CTP_folder = dir(fullfile(study_name.folder,study_name.name,CTP_series_name));
                [~,byte_idx] = max([CTP_folder.bytes]);
                CTP_file = dicominfo(fullfile(CTP_folder(byte_idx).folder,CTP_folder(byte_idx).name));
            catch
                fileID = fopen(flagFile,'w');
                fclose(fileID);
                errorFlagFile = fullfile(errorFlagPath,[subject_name,'_error_loading_CTP.txt']);
                fid = fopen(errorFlagFile,'w');
                fclose(fid);
                fprintf('Error loading CTP series for %s.\n',subject_name);
                continue;
            end
        end
    end
    
    % Create map of all NCCT z-locations
    % - Loop through each dcm file
    try
        for ii = 1:length(NCCT_files)
            NCCT_file = NCCT_files(ii);
            if strcmp(NCCT_file.name(1),'.'),continue;end
            NCCT_filepath = fullfile(NCCT_file.folder,NCCT_file.name); % Construct filepath to NCCT file
            NCCT_info = dicominfo(NCCT_filepath);                      % Read NCCT dcm info
            coords = NCCT_info.ImagePositionPatient;
            z_coord = coords(3);
            NCCT_zcoords(z_coord) = NCCT_filepath;
        end
    catch
        fileID = fopen(flagFile,'w');
        fclose(fileID);
        errorFlagFile = fullfile(errorFlagPath,[subject_name,'_error_NCCT_coordinates.txt']);
        fid = fopen(errorFlagFile,'w');
        fclose(fid);
        fprintf("Cannot find NCCT coordinates for %s\n", subject.name)
        continue;
    end
    
    try
        for ii = 1:length(fieldnames(CTP_file.PerFrameFunctionalGroupsSequence))
            fieldname = ['Item_', num2str(ii)];
            coords = CTP_file.PerFrameFunctionalGroupsSequence.(fieldname).PlanePositionSequence.Item_1.ImagePositionPatient;
            z_coord = coords(3);
            CTP_zcoords(z_coord) = string(ii);
        end
    catch
        fileID = fopen(flagFile,'w');
        fclose(fileID);
        errorFlagFile = fullfile(errorFlagPath,[subject_name,'_missing_metadata_ImagePositionPatient.txt']);
        fid = fopen(errorFlagFile,'w');
        fclose(fid);
        fprintf("Cannot find metadata for ImagePositionPatient for %s\n", subject.name)
        continue;
    end
    
    % Convert the stored z-coordinates into a useable matrix
    NCCT_zs = cell2mat(keys(NCCT_zcoords));
    CTP_zs = cell2mat(keys(CTP_zcoords));
    slice_num = 1;
    
    % Avoid first and last 3 NCCT slices. Also skip every 4 slices?
    for jj = 1:offset_range:length(NCCT_zcoords)
        
        % Grab a z-coord
        NCCT_z = NCCT_zs(jj);
        
        % Use the z-coord to find a match within 'match_threshold'.
        % (If larger than slice threshold, don't match)
        [closest_val,idx] = min(abs(CTP_zs-NCCT_z));
        closest_val = closest_val(1);
        if closest_val >= match_threshold, continue; end
        CTP_z = CTP_zs(idx);
        correspondingSlice = str2num(CTP_zcoords(CTP_z)); % Slice number (3rd dim) to get from CTP volume
        
        % (Don't match if offset slices are not found either)
        NCCTplus_z = NCCT_zs(jj)+4;
        [closest_plus,idplus] = min(abs(NCCT_zs-NCCTplus_z));
        if closest_plus >= NCCT_slice_offset, continue; end
        NCCTplus_z = NCCT_zs(idplus);
        
        NCCTminus_z = NCCT_zs(jj)-4;
        [closest_minus,idminus] = min(abs(NCCT_zs-NCCTminus_z));
        if closest_minus >= NCCT_slice_offset, continue; end
        NCCTminus_z = NCCT_zs(idminus);

        if idplus < 1 || idplus > length(NCCT_zs) || idminus < 1 || idminus > length(NCCT_zs), continue; end
        
        % Get images. NCCT use path. CTP use slice number
        NCCT_file = NCCT_zcoords(NCCT_z);
        NCCT_img = processNCCT(NCCT_file, ub, dsize);
        if nnz(NCCT_img)/numel(NCCT_img) < 0.2, continue; end
        
        NCCTplus_file = NCCT_zcoords(NCCTplus_z);
        NCCTplus_img = processNCCT(NCCTplus_file, ub, dsize);
        
        NCCTminus_file = NCCT_zcoords(NCCTminus_z);
        NCCTminus_img = processNCCT(NCCTminus_file, ub, dsize);
        
        % Re-apply main mask to offset slices
        mask = NCCT_img ~= 0;
        NCCT_img(~mask)= 0;
        NCCTplus_img(~mask)= 0;
        NCCTminus_img(~mask)= 0;
        
        % Concatenate all 3 slices together
        NCCT_img = cat(3, NCCTminus_img, NCCT_img, NCCTplus_img);
        
        % Convert perfusion map to specific ranges and save appropriately
        % -- CBF: 0-60, CBV: 0-4, MTT: 0-12, TTP: 0-25
        try
            CBF_path = fullfile(fstrokePath,subject_name,'cbf.nii.gz');
            processPerf(CBF_path,partitionPath,subject_name,correspondingSlice,jj,mask,'cbf')
    
            CBV_path = fullfile(fstrokePath,subject_name,'cbv.nii.gz');
            processPerf(CBV_path,partitionPath,subject_name,correspondingSlice,jj,mask,'cbv')
    
            MTT_path = fullfile(fstrokePath,subject_name,'mtt.nii.gz');
            processPerf(MTT_path,partitionPath,subject_name,correspondingSlice,jj,mask,'mtt')
    
            TTP_path = fullfile(fstrokePath,subject_name,'tmax.nii.gz');
            processPerf(TTP_path,partitionPath,subject_name,correspondingSlice,jj,mask,'ttp')
        
        catch
            fileID = fopen(flagFile,'w');
            fclose(fileID);
            errorFlagFile = fullfile(errorFlagPath,[subject_name,'_missing_FSTROKE.txt']);
            fid = fopen(errorFlagFile,'w');
            fclose(fid);
            fprintf("Missing FSTROKE output for %s\n", subject.name)
            continue;
        end

        % Save NCCT image
        saveName = strcat(subject_name,'_',num2str(jj),'.png');
        savePath = fullfile(partitionPath,'NCCT',saveName);
        imwrite(NCCT_img,savePath)

    end
%     % Skip the first 4 and last 4 slices.
%     first_slice_loc = NCCT_slice_offset+1;    
%     last_slice_loc = first_slice_loc + offset_range * floor((length(NCCT_files)-first_slice_loc) / offset_range);
%     slices = linspace(first_slice_loc, last_slice_loc,(last_slice_loc-first_slice_loc)/offset_range+1);
%     slices = slices(5:end-4);
%     
%     % Loop through main slices given offset [-offset | main | +offset]
%     for jj = 1:length(slices)
%         ii = slices(jj);
% 
%         % Process NCCT slice given img and info. Repeat with offset slices
%         NCCT_file = NCCT_files(ii);
%         NCCT_img = processNCCT(NCCT_file, ub, dsize);
%         
%         NCCTplus_file = NCCT_files(ii+NCCT_slice_offset);
%         NCCTplus_img = processNCCT(NCCTplus_file, ub, dsize);
% 
%         NCCTminus_file = NCCT_files(ii-NCCT_slice_offset);
%         NCCTminus_img = processNCCT(NCCTminus_file, ub, dsize);
% 
%         % Re-apply main mask to offset slices
%         mask = NCCT_img ~= 0;
%         NCCT_img(~mask)= 0;
%         NCCTplus_img(~mask)= 0;
%         NCCTminus_img(~mask)= 0;
%         
%         % Concatenate all 3 slices together
%         NCCT_img = cat(3, NCCTminus_img, NCCT_img, NCCTplus_img);
% 
%         % Save NCCT image
%         saveName = strcat(subject_name,'_',num2str(jj),'.png');
%         savePath = fullfile(partitionPath,'NCCT',saveName);
%         imwrite(NCCT_img,savePath)
%         
%         % Convert perfusion map to specific ranges and save appropriately
%         % -- CBF: 0-60, CBV: 0-4, MTT: 0-12, TTP: 0-25
%         CBF_path = fullfile(fstrokePath,subject_name,'cbf.nii.gz');
%         processPerf(CBF_path,partitionPath,subject_name,ii,jj,mask,'cbf')
% 
%         CBV_path = fullfile(fstrokePath,subject_name,'cbv.nii.gz');
%         processPerf(CBV_path,partitionPath,subject_name,ii,jj,mask,'cbv')
% 
%         MTT_path = fullfile(fstrokePath,subject_name,'mtt.nii.gz');
%         processPerf(MTT_path,partitionPath,subject_name,ii,jj,mask,'mtt')
% 
%         TTP_path = fullfile(fstrokePath,subject_name,'tmax.nii.gz');
%         processPerf(TTP_path,partitionPath,subject_name,ii,jj,mask,'ttp')
%         
%     end
    fileID = fopen(flagFile,'w');
    fclose(fileID);
    fprintf('> Finished with subject %s\n',subject_name);
end
fprintf("------------------------------------------------------------------\n")
fprintf("Finished...matchNCCTandFSTROKE.m\n")
fprintf("------------------------------------------------------------------\n")

end

%% Local Functions
function processPerf(dataPath,partitionPath,subject_name,loc,jj,mask,type)
    % -- Process perfusion map and save based on type --
    % To debug how slices look:
    % imshow(CBV_slice, [0 25])
    % figure; imshow(CBV_slice, [0 25])

    % 
    map = niftiread(dataPath);
    slice = imrotate(map(:,:,loc),270);
    slice = uint8(normalize(slice,"range",[0 60]));
    slice = imadjust(slice);
    slice = imresize(slice,[256 256]); % Resize after making all changes
    slice(~mask) = 0; % Apply mask
    if type == 'cbf' 
        saveName = strcat(subject_name,'_',num2str(jj),'.png');
        savePath = fullfile(partitionPath,'rCBF',saveName);
        imwrite(slice,savePath)
    elseif type == 'cbv'
        saveName = strcat(subject_name,'_',num2str(jj),'.png');
        savePath = fullfile(partitionPath,'rCBV',saveName);
        imwrite(slice,savePath)
    elseif type == 'mtt'
        saveName = strcat(subject_name,'_',num2str(jj),'.png');
        savePath = fullfile(partitionPath,'MTT',saveName);
        imwrite(slice,savePath)
    elseif type == 'ttp'
        saveName = strcat(subject_name,'_',num2str(jj),'.png');
        savePath = fullfile(partitionPath,'TTP',saveName);
        imwrite(slice,savePath)
    else
        fprintf("Perfusion type unrecognized")
    end
    
end

function img = processNCCT(file, ub, dsize)
    % -- Process NCCT using pct tools to mask twice --
    % Read dicom image and metadata
    img = dicomread(file);
    info = dicominfo(file);
    
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