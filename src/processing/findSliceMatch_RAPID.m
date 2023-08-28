function [] = findSliceMatch_RAPID(datasetPath,outputPath)
%% Match NCCT and CTP Perfusion Map Slices
% This is the main function for matching NCCT and CTP perfusion map slices.
% This function requires that the dataset contain NCCT and Perfusion Map
% data. The steps performed in this function include:
%
%   - Aggregate all NCCT and Perfusion Map slices
%   - List out all z-locations from slices
% 
% NCCT expected at 1.0mm resolution with 160 slices. Z coordinates are
% taken from NCCT and each CTP slice. CTP slices are matched within 2mm of
% NCCT z slice. Two slices offset from main NCCT slice are also taken and
% stacked together.
% 
%   Garrett Fullerton 10/18/2020
%   Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%   Biomedical Engineering
% 
%   Input:
%       datasetPath   - Path to input folder containing deid subjects
%       outputPath    - Path to output folder
% 
%----------------------------------------
% Last Updated: 5/26/2023 by KS
% Create v4.
% add gui and update selection methods
%
% 8/22/2023 by KS
% 
% - Resolved an issue where the index for NCCT slice is exceeded.
% - Resolved an issue where the index for NCCT slice is undercut.
% - Resolved an issue with selecting from multiple NCCT modalities. The
%   NCCT keyword is prioritized first, then other filenames, and lastly
%   summary files.
% 
% 8/21/2023 by KS
% - Changed script into a function.
% - Adjusted printing text.
% 
% 5/26/2023 by KS
% - Added comments and description
% - Added a function to fix multiple study folders by combining them
% - Added a function to fix multiple series folders by combining them
% - Changed some variable names to be more intuitive
% - Fixed missing local function "getCorrectImage"
% - Changed paths of utilities from absolute to relative
% 
% 11/1/2020 by GF
% - Create v4
% - Added gui and update selection methods


%outline
%index all the NCCT slices and get a list of the z-locations
%get a list of all the maps files
%for ONE modality of the maps files (length/4)
    %find the closest NCCT
    %find the matching slices from the other modalities
    %^^slice_num=length/4 * i + idx (for i=1:3, idx = idx between
    %1,length/4)
    %name everything the same and save everything
    %increment slice idx
%done!

%% Adjustable Variables
%#########################################
% clc; clear; close all; warning off;
% % Input folder - folders must follow the order
% % > Subject -> Study -> Session -> Image
% datasetPath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\test';
% % Output folder - will be created
% outputPath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\test_output';
%#########################################

fprintf("Starting...findSliceMatch_RAPID.m\n")
fprintf("------------------------------------------------------------------\n")

% Fix any issues with study or series folders
fixStudy(datasetPath)
fixSeries(datasetPath)

% Add utilities
addpath('../toolbox/utilities')

% What is this? It is 3-columns with values in them.
% This is a colormap
% load('RAPID_U.mat'); % Found in /src/toolbox/roi_performance
load('../toolbox/roi_performance/RAPID_U.mat','Rapid_U')

NCCT_slice_offset = 4; % integer greater than 0 - How many slices to offset from the main NCCT slice
match_threshold = 2; % Maximum threshold for finding matching Perfusion map slice 
dsize = 7; % Disk radius for morphological closing, used in Fang's PCT function (originally 7)
ub = 200; % Upperbound, used in Fang's PCT function
startNum=1;
save_check = 'y'; % Save or not

% This file contains text MTT_test, TTP_test, rCBF_test, and rCBV_test.
% These files are pictures of the the corresponding words. These are used
% to determine which image belongs to which perfusion map.
load('RAPIDModalities.mat','MTT_test','TTP_test','rCBF_test','rCBV_test');

if ~exist(fullfile(outputPath),'dir'), mkdir(fullfile(outputPath)); end

%NCCTPath = fullfile(outputPath,'NCCT');
%mapsPath = fullfile(outputPath,'maps');
%MIPtempPath = fullfile(outputPath,'MIP_temp');

%if ~exist(NCCTPath,'dir'), mkdir(NCCTPath); end
%if ~exist(MIPtempPath,'dir'), mkdir(MIPtempPath); end
%if ~exist(mapsPath,'dir'), mkdir(mapsPath); end

%MIPPath = fullfile(outputPath, 'MIP');
rCBVPath = fullfile(outputPath, 'rCBV');
TTPPath = fullfile(outputPath, 'TTP');
rCBFPath = fullfile(outputPath,'rCBF');
MTTPath = fullfile(outputPath, 'MTT');
%DelayPath = fullfile(outputPath, 'Delay');
NCCTsavePath = fullfile(outputPath, 'NCCT');

%if ~exist(MIPPath,'dir'), mkdir(MIPPath); end
if ~exist(rCBVPath,'dir'), mkdir(rCBVPath); end
if ~exist(TTPPath,'dir'), mkdir(TTPPath); end
if ~exist(rCBFPath,'dir'), mkdir(rCBFPath); end
if ~exist(MTTPath,'dir'), mkdir(MTTPath); end
%if ~exist(DelayPath,'dir'), mkdir(DelayPath); end
if ~exist(NCCTsavePath,'dir'), mkdir(NCCTsavePath); end

%skipped_subjects = struct;
skip_idx = 1;

% Checkpoint files to skip subjects.
flagPath = fullfile(datasetPath,'completed');
if ~exist(flagPath,'dir'), mkdir(flagPath); end

subjects = dir(datasetPath); % Directory list of input folders
subjects(end) = [];

%% Get all file paths in one place
% Loop through all subjects in input folder (skips hidden)
parfor j = startNum+2:length(subjects)
    
    % Grab subject name
    subject = subjects(j);
    subject_name = subject.name;
    
    % Skip file if already complete
    flagFile = fullfile(flagPath,[subject_name,'.txt']);
    if exist(flagFile,'file')
        fprintf("> Subject %s already processed\n",subject_name)
        continue;
    end
       
    [~,~,ext] = fileparts(fullfile(subject.folder,subject_name));  % Get extension
    if strcmp(ext,'.csv') || strcmp(ext,'.xlsx'), continue; end    % Skip if it isn't a study folder
    if strcmp(subject_name(1),'.'), continue; end                  % Skip if it isn't a study folder
    fprintf('Processing subject %s\n',subject_name);
    
    study_name = dir(fullfile(subject.folder,subject.name));
    study_name = study_name(3);
    series_all = dir(fullfile(study_name.folder,study_name.name));
    series_names = {series_all.name}; % Grab all series names
    
    % Set up containers (python dict equivalent)
    NCCT_zcoords = containers.Map('KeyType','double','ValueType','char');
    rCBV_zcoords = containers.Map('KeyType','double','ValueType','char');
    rCBF_zcoords = containers.Map('KeyType','double','ValueType','char');
    MTT_zcoords = containers.Map('KeyType','double','ValueType','char');
    TTP_zcoords = containers.Map('KeyType','double','ValueType','char');
    
    % Indexing, looking for the NCCT series using keywords
    NCCT_idx = contains(series_names,'without','IgnoreCase',true);
    NCCT_idx = or(NCCT_idx,contains(series_names,'W-O','IgnoreCase',true));
    NCCT_idx = or(NCCT_idx,contains(series_names,'NCCT','IgnoreCase',true));
    NCCT_idx = or(NCCT_idx,contains(series_names,'NON-CON','IgnoreCase',true));
    NCCT_idx = or(NCCT_idx,contains(series_names,'NON_CON','IgnoreCase',true));
    NCCT_idx = and(NCCT_idx,~contains(series_names,'bone','IgnoreCase',true));
    
    % Indexing, looking for the RAPID series using keywords
    maps_idx = contains(series_names,'rapid','IgnoreCase',true);
    maps_idx = and(maps_idx,contains(series_names,'maps','IgnoreCase',true));
    
    % Grab ALL files from the NCCT series
    NCCT_series = []; maps_series = [];
    if ~any(NCCT_idx) % Cannot find an NCCT series
        fprintf('Cannot locate NCCT series for subject %s. Please select the correct directory.\n',subject.name);
        NCCT_selpath = uigetdir(fullfile(study_name.folder,study_name.name),'NCCT Folder');
        NCCT_files = dir(NCCT_selpath);
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
    
    % Grab ALL files from the RAPID series
    if ~any(maps_idx)
        fprintf('Cannot locate PerfusionMap series for subject %s. Please select the correct directory.\n',subject.name);
        maps_selpath = uigetdir(fullfile(study_name.folder,study_name.name),'Perfusion Maps Folder');
        maps_files = dir(maps_selpath);
    else
        maps_series = series_names(maps_idx);
        maps_series_name = string(maps_series(1));
        maps_selpath = fullfile(study_name.folder,study_name.name,maps_series_name);
        maps_files = dir(fullfile(study_name.folder,study_name.name,maps_series_name,'*.dcm'));
    end
    
    % Remove map files that aren't maps
    for i = length(maps_files):-1:1
        thismap = maps_files(i);
        if strcmp(thismap.name(1),'.')
            maps_files(i) = [];
        end
    end
    
    % Create map of all NCCT z-locations
    % - Loop through each dcm file    
    for i = 1:length(NCCT_files)
        NCCT_file = NCCT_files(i);                                 % Read 1 dcm at a time
        if strcmp(NCCT_file.name(1),'.'),continue;end              % Skip non-dcm file 
        NCCT_filepath = fullfile(NCCT_file.folder,NCCT_file.name); % Construct filepath to NCCT file
        NCCT_info = dicominfo(NCCT_filepath);                      % Read NCCT dcm info
        coords = NCCT_info.ImagePositionPatient;                   % Read Image Position (Patient) field
        z_coord = coords(3);                                       % Third number in the image position (patient)
        NCCT_zcoords(z_coord) = NCCT_filepath;
    end
    
    % Create map of all RAPID z-locations
    % - Loop through each dcm file
    for i = 1:length(maps_files)
        map_file = maps_files(i);                                  % Read 1 dcm at a time
        if strcmp(NCCT_file.name(1),'.'),continue;end              % Skip non-dcm file
        map_filepath = fullfile(map_file.folder,map_file.name);    % Construct filepath to RAPID file
        map_info = dicominfo(map_filepath);                        % Read RAPID dcm info
        map_img = dicomread(map_filepath);                         % Read RAPID image
        coords = map_info.ImagePositionPatient;                    % Read Image Position (Patient) field
        z_coord = coords(3);                                       % Third number in the image position (patient)
        
        % Identifies perfusion map type
        modality = identifyRAPIDModality(map_img, TTP_test, rCBV_test, rCBF_test, MTT_test);
        
        % Add coords to perfusion map type
        switch modality
            case 'rCBV'
                rCBV_zcoords(z_coord) = map_filepath;
            case 'rCBF'
                rCBF_zcoords(z_coord) = map_filepath;
            case 'MTT'
                MTT_zcoords(z_coord) = map_filepath;
            case 'TTP'
                TTP_zcoords(z_coord) = map_filepath;
        end
    end
    
    % Convert z-coords into matrix
    NCCT_zs = cell2mat(keys(NCCT_zcoords));
    rCBV_zs = cell2mat(keys(rCBV_zcoords));
    rCBF_zs = cell2mat(keys(rCBF_zcoords));
    MTT_zs = cell2mat(keys(MTT_zcoords));
    TTP_zs = cell2mat(keys(TTP_zcoords));
    slice_num = 1;
    
    % go through each map (one modality only in loop)
    %for i = 1:length(rCBV_zcoords)
    % Truncate first and last 3 coords

%     % Used to check for progress. Replaced by flag system.
%     total_slices = (length(rCBV_zcoords)-3)-4+1;
% 
%     checkOutput = 0;
%     for ii = 1:total_slices
%         img_name = strcat(extractBefore(subject_name,'_'),'_',num2str(ii),'.bmp');
%         if exist(fullfile(rCBVPath,img_name),'file')
%             checkOutput = checkOutput+1;
%         end
%         if exist(fullfile(TTPPath,img_name),'file')
%             checkOutput = checkOutput+1;
%         end
%         if exist(fullfile(rCBFPath,img_name),'file')
%             checkOutput = checkOutput+1;
%         end
%         if exist(fullfile(MTTPath,img_name),'file')
%             checkOutput = checkOutput+1;
%         end
%         if exist(fullfile(NCCTsavePath,img_name),'file')
%             checkOutput = checkOutput+1;
%         end
% 
%     end
%     if checkOutput == total_slices*5
%         fprintf("> Subject %s already processed\n",subject_name)
%         continue;
%     end
        
    % Go through each map (one modality only in loop)
    for i = 4:length(rCBV_zcoords)-3
        
        % Grab a z-coord
        rCBV_z = rCBV_zs(i);
        
        % Clean and crop image, leave only brain slice
        rCBV_img = getCorrectImage(rCBV_zcoords,rCBV_z);
        
        % Take z-coord and find match with CBF
        % (If larger than slice threshold, don't match)
        [closest_val,idx] = min(abs(rCBF_zs-rCBV_z));    % Find closest match in CBF coords
        closest_val = closest_val(1);                    % Set closest value
        if closest_val >= match_threshold, continue; end % Apply slice threshold
        rCBF_z = rCBF_zs(idx);                           % Grab similar z-coord from CBF
        rCBF_img = getCorrectImage(rCBF_zcoords,rCBF_z); % Clean and crop image, leave only brain slice
        
        % Take z-coord and find match with MTT (similar as above)
        [closest_val,idx] = min(abs(MTT_zs-rCBV_z));
        closest_val = closest_val(1);
        if closest_val >= match_threshold, continue; end
        MTT_z = MTT_zs(idx);
        MTT_img = getCorrectImage(MTT_zcoords,MTT_z);
        
        % Take z-coord and find match with TTP (similar to above)
        [closest_val,idx] = min(abs(TTP_zs-rCBV_z));
        closest_val = closest_val(1);
        if closest_val >= match_threshold, continue; end
        TTP_z = TTP_zs(idx);
        TTP_img = getCorrectImage(TTP_zcoords,TTP_z);
        
        % Take z-coord and find match with NCCT
        [closest_val,idx] = min(abs(NCCT_zs-rCBV_z));
        
        % Find 2 offset slices from main slice match
        if idx+NCCT_slice_offset > length(NCCT_zs) || idx-NCCT_slice_offset < 1, continue; end
        NCCT_z_1 = NCCT_zs(idx-NCCT_slice_offset);
        NCCT_z_2 = NCCT_zs(idx);
        NCCT_z_3 = NCCT_zs(idx+NCCT_slice_offset);
        
        % Grab file path of the slices
        NCCT_name_1 = NCCT_zcoords(NCCT_z_1);
        NCCT_name_2 = NCCT_zcoords(NCCT_z_2);
        NCCT_name_3 = NCCT_zcoords(NCCT_z_3);
        
        % Read in NCCT slices using DCM info
        NCCT_img_1 = dicomread(NCCT_name_1); NCCT_info_1 = dicominfo(NCCT_name_1);
        NCCT_img_1 = convert_DICOM_to_uint8(NCCT_img_1,NCCT_info_1);
        NCCT_img_2 = dicomread(NCCT_name_2); NCCT_info_2 = dicominfo(NCCT_name_2);
        NCCT_img_2 = convert_DICOM_to_uint8(NCCT_img_2,NCCT_info_2);
        NCCT_img_3 = dicomread(NCCT_name_3); NCCT_info_3 = dicominfo(NCCT_name_3);
        NCCT_img_3 = convert_DICOM_to_uint8(NCCT_img_3,NCCT_info_3);
        
        % Apply brain mask to first offset slice
        NCCT_img_store_1 = NCCT_img_1;
        NCCT_mask_1 = pct_brainMask_noEyes(NCCT_img_1, 0, ub, dsize);
        NCCT_img_1(~NCCT_mask_1) = 0;
        NCCT_mask2_1 = pct_brainMask_noEyes(NCCT_img_1, 0, ub, 4);
        NCCT_img_1(~NCCT_mask2_1) = 0;
        
        % Compare NCCT_pre, NCCT_mask, and NCCT_masked
%         figure; subplot(1,3,1); imshow(NCCT_img_store_1); subplot(1,3,2); imshow(NCCT_mask_1); subplot(1,3,3); imshow(NCCT_img_1)
        
        % Apply brain mask to main slice
        NCCT_img_store_2 = NCCT_img_2;
        NCCT_mask_2 = pct_brainMask_noEyes(NCCT_img_2, 0, ub, dsize);
        NCCT_img_2(~NCCT_mask_2) = 0;
        NCCT_mask2_2 = pct_brainMask_noEyes(NCCT_img_2, 0, ub, 4);
        NCCT_img_2(~NCCT_mask2_2) = 0;
        
        % Apply brain mask to second offset slice
        NCCT_img_store_3 = NCCT_img_3;
        NCCT_mask_3 = pct_brainMask_noEyes(NCCT_img_3, 0, ub, dsize);
        NCCT_img_3(~NCCT_mask_3) = 0;
        NCCT_mask2_3 = pct_brainMask_noEyes(NCCT_img_3, 0, ub, 4);
        NCCT_img_3(~NCCT_mask2_3) = 0;
        
        % Reshape the NCCT image to have the same dimensions as perfusion
        NCCT_img_1 = imresize(NCCT_img_1,[256 256]);
        NCCT_img_2 = imresize(NCCT_img_2,[256 256]);
        NCCT_img_3 = imresize(NCCT_img_3,[256 256]);
        
        % Re-apply main mask to all selected slices
        mask_fin = (NCCT_img_2 ~= 0);
        NCCT_img_1(~mask_fin)=0;
        NCCT_img_2(~mask_fin)=0;
        NCCT_img_3(~mask_fin)=0;
        
        % Concatenate all 3 slices together
        NCCT_img = cat(3, NCCT_img_1, NCCT_img_2, NCCT_img_3);
        
        % Create save name using subject ID + slice number
        saveName = strcat( extractBefore(subject_name,'_'),'_',num2str(slice_num),'.bmp');
        
        % Apply NCCT mask
        MTT_img_fin = applyNCCTMask(MTT_img,mask_fin);
        rCBF_img_fin = applyNCCTMask(rCBF_img,mask_fin);
        rCBV_img_fin = applyNCCTMask(rCBV_img,mask_fin);
        TTP_img_fin = applyNCCTMask(TTP_img,mask_fin);
        
        % If blank image, skip
        if all(NCCT_img_1(:)==0) || all(NCCT_img_2(:)==0) || all(NCCT_img_3(:)==0)
            continue;
        elseif all(MTT_img_fin(:)==0) || all(rCBF_img_fin(:)==0) || all(rCBV_img_fin(:)==0) || all(TTP_img_fin(:)==0)
            continue;
        end

        if contains(save_check,'y') || contains(save_check,'Y')
            
            rCBV_img_fin = uint8(rgb2values(rCBV_img_fin,Rapid_U,'gray'));
            TTP_img_fin = uint8(rgb2values(TTP_img_fin,Rapid_U,'gray'));
            rCBF_img_fin = uint8(rgb2values(rCBF_img_fin,Rapid_U,'gray'));
            MTT_img_fin = uint8(rgb2values(MTT_img_fin,Rapid_U,'gray'));

            parsave(fullfile(rCBVPath, saveName), rCBV_img_fin);
            parsave(fullfile(TTPPath, saveName), TTP_img_fin);
            parsave(fullfile(rCBFPath, saveName), rCBF_img_fin);
            parsave(fullfile(MTTPath, saveName), MTT_img_fin);
            
            parsave(fullfile(NCCTsavePath, saveName), NCCT_img);
            slice_num=slice_num+1;
        end
    end
    fileID = fopen(flagFile,'w');
    fclose(fileID);
    fprintf('> Finished with subject %s\n',subject_name);
end
fprintf("------------------------------------------------------------------\n")
fprintf("Finished...findSliceMatch_RAPID.m\n")
fprintf("------------------------------------------------------------------\n")

end

%% Local Functions
function FINAL_img = getCorrectImage(MODALITY_zcoords,TEST_IMG)
    TEST_IMG_name = MODALITY_zcoords(TEST_IMG);
    FINAL_img = dicomread(TEST_IMG_name); % Read perfusion img given dict
    FINAL_img(:,1:30,:)=0; % Crop left-side for uniformity
    FINAL_img(1:30,:,:)=[]; % Crop title for uniformity
end