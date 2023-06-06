function [] = fixStudy(datasetPath)
%% Fix Study Folder
% This function fixes the issue of multiple study folders. The
% DICOM-deidentification code may create an extra folder with an untitled
% name. This leaves 'findSliceMatch_RAPID.m' unable to find the appropriate
% files. The files are merged under the normalized name
% 'CTA_HEAD_PERF_AND_NECK...'.
% 
%   Kyle See 05/26/23
%   Smart Medical Informatics Learning and Evaluation (SMILE)
%   Biomedical Engineering
% 
%   Input:
%       datasetPath   - Path to input folder containing subjects
% 
%---------------------------------------------
% Last Updated: 5/26/2023

%% Code
% Testing settings
% To test: Comment function. | Uncomment lines between hash below
% #########################################
% clc;clear;close all; warning off;
% datasetPath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\fixStudy_input';
% #########################################

% Get directory containing all subjects
subjects = dir(datasetPath);

% Determines print output
merge_flag = 0;

% Loops through all subjects
for i = 3:length(subjects)
    subject = subjects(i);
    subject_name = subject.name;
    
    % Get directory for a subject
    dir_study = dir(fullfile(datasetPath,subject_name));
    
    % Combine folders if CTA_HEAD folder exists and extra folder exists.
    % Ignore data_summary.csv and data_summary.xlsx.
    % Expects 5 files: CTA_HEAD study, 2 hidden dir, 2 data_summaries
    if length(dir_study) > 5
        merge_flag = 1;
        % Start 3 to skip hidden dir . and ..
        for j = 3:length(dir_study)
            if contains(dir_study(j).name,'CTA') % Gets the CTA folder name
                cta_folder = dir_study(j).name;
            elseif contains(dir_study(j).name,'data_summary') % Skip data summary
                continue;
            else % Get extra folder name
                fprintf("Other folder detected in %s: %s\n",subject_name,dir_study(j).name)
                extra_folder = dir_study(j).name;
            end
        end
        % Get extra directory
        dir_extra = dir(fullfile(datasetPath,subject_name,extra_folder));
        fprintf("Merging %d files\n",length(dir_extra)-2)
        
        % Move all files to CTA folder
        for k = 3:length(dir_extra)
           file_input = fullfile(datasetPath,subject_name,extra_folder,dir_extra(k).name);
           file_output = fullfile(datasetPath,subject_name,cta_folder,dir_extra(k).name);
           movefile(file_input,file_output)
        end
        
        % Remove extra folder
        extra_folder_path = fullfile(datasetPath,subject_name,extra_folder);
        rmdir(extra_folder_path)
        fprintf("Merge complete. Extra folder deleted.\n")
    end
end

if merge_flag == 0
    fprintf("No issues with study folder found.\n")
else
    fprintf("All issues resolved.\n")
end
fprintf("------------------------------------------------------------------\n")

end