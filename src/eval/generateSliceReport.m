%% Vertically concatenate slice comparisons for whole subject reports
% The current use of this code is to combine the slice comparisons for each
% subject. This requires the output from generateSliceComparison.m. The
% order of the files follows: NCCT, Real CTP maps, Fake CTP maps. 
% 
%   Kyle See 09/05/2023
%   Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%   Biomedical Engineering
% 
%----------------------------------------
% Last Updated: 8/28/2023 by KS
% 
%% Adjustable Variables
% #########################################
close all; clear; clc;
evalPath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\dataset_A3_results_eval';
% #########################################

fprintf("Starting...generateSliceReport.m\n")
fprintf("------------------------------------------------------------------\n")

% Setup file paths
input_folder = fullfile(evalPath,'slice');
output_folder = fullfile(evalPath,'report');

% Create file paths if needed
if ~exist(output_folder,'dir'),mkdir(output_folder);end

% Create directories and remove . and ..
slice_files = dir(input_folder);
slice_files(1:2) = []; % Remove . and ..
subj_names = slice_files; % Duplicate struct to find unique subj

% Find all unique subj names
for i = 1:length(slice_files)
    % Find the underscore position(YYYYYYY_X.png)
    underscore_index = strfind(slice_files(i).name, '_');
    
    % Extract ID
    if ~isempty(underscore_index)
        subj_names(i).name = slice_files(i).name(1:underscore_index-1);
    end
end

% Convert to cell array
subj_array = {subj_names.name}';
unique_names = unique(subj_array);

for j = 1:length(unique_names)
    % Construct filename
    name = [unique_names{j},'_1.png']; % Initial filename will change in while loop
    filepath = fullfile(input_folder,name);
    
    % Initialize while loop
    image_number = 1;
    slice_report = [];
    
    while exist(filepath,'file')
        % Concatenate slices
        slice_img = imread(filepath);
        slice_report = cat(1,slice_report,slice_img);
        
        % Update filename
        image_number = image_number + 1;
        name = [unique_names{j},'_',num2str(image_number),'.png'];
        filepath = fullfile(input_folder,name);
    end
    
    save_name = fullfile(output_folder,[unique_names{j},'.png']);
    imwrite(slice_report,save_name)
    fprintf("Saved %s report.\n",unique_names{j})
end

fprintf("------------------------------------------------------------------\n")
fprintf("Finished...generateSliceReport.m\n")
fprintf("------------------------------------------------------------------\n")