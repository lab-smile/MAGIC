% function [] = matchNCCTandFSTROKE(deidPath,fstrokePath,partitionPath)
%% Match NCCT and FSTROKE Perfusion Map Slices
% This is the main function for matching NCCT and FSTROKE perfusion map
% slices. This function requires that the dataset contains NCCT and
% Perfusion Map data. The steps performed in this function include:
% 
%   - Aggregate all NCCT and perfusion map slices.
%   - List out all z-locations from slices
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
fprintf("Starting...matchNCCTandFSTROKE.m\n")
fprintf("------------------------------------------------------------------\n")

% Fix any issues with study or series folders
fix_study(deidPath)
fix_series(deidPath)

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

% Checkpoint files to skip subjects
flagPath = fullfile(deidPath,'completed');
if ~exist(flagPath,'dir'), mkdir(flagPath); end
subjects = dir(deidPath);   % Directory list of input folders
subjects(end) = [];         % Get rid of "completed" folder
subjects(1:2) = [];         % Get rid of . and ..

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
    NCCT_idx = and(NCCT_idx,~contains(series_names,'5.0','IgnoreCase',true));

    % Grab ALL files from the NCCT series
    NCCT_series = []; maps_series = [];
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

    % Create map of all NCCT z-locations
    for j = 1:length(NCCT_files)
        NCCT_file = NCCT_files(i);                                 % Read 1 dcm at a time
        if strcmp(NCCT_file.name(1),'.'),continue;end              % Skip non-dcm file 
        NCCT_filepath = fullfile(NCCT_file.folder,NCCT_file.name); % Construct filepath to NCCT file
        NCCT_info = dicominfo(NCCT_filepath);                      % Read NCCT dcm info
        coords = NCCT_info.ImagePositionPatient;                   % Read Image Position (Patient) field
        z_coord = coords(3);                                       % Third number in the image position (patient)
        disp(z_coord)
        NCCT_zcoords(z_coord) = NCCT_filepath;
    end

end



% end