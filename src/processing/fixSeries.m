function [] = fixSeries(datasetPath)
%% Fix Series Folders
% This function fixes the issue of multiple series folders. The
% DICOM-deidentification code may have given each .dcm file its own folder.
% This results in multiple folders created for a single modality. The files
% are merged into respective folders. ASSUMES fixStudy has fixed the
% multiple study folder issue if present.
% 
%   Kyle See 08/10/23
%   Smart Medical Informatics Learning and Evaluation (SMILE)
%   Biomedical Engineering
% 
%   Input:
%       datasetPath     - Path to input folder containing subjects
% 
%---------------------------------------------
% Last Updated: 08/10/2023

%% Code
% Testing settings
% To test: Comment function. | Uncomment lines between hash below
% #########################################
% clc;clear; close all; warning off;
% datasetPath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\fix';
% #########################################

% Get directory containing all subjects
subjects = dir(datasetPath);

% Loops through all subjects
for i = 3:length(subjects)
    subject = subjects(i);
    subject_name = subject.name;
    
    % Get directory for a subject
    dir_study = dir(fullfile(datasetPath,subject_name));
    
    for j = 3:length(dir_study)
        if contains(dir_study(j).name,'CTA')
            cta_folder = dir_study(j).name;
            continue;
        end
    end
    
    dir_cta = dir(fullfile(datasetPath,subject_name,cta_folder));
    dir_cta = {dir_cta([dir_cta.isdir]).name}';
    dir_cta = dir_cta(~ismember(dir_cta, {'.', '..'}));
    
    % Grab a list of repeated folders
    folderGroups = containers.Map();
    
    for ii = 1:numel(dir_cta)
        subfolderName = dir_cta{ii};
        if strcmp(subfolderName, '2.0')
            continue;
        end

        % Check if the subfolder name for patterns filename.X
        pattern = '^(.*?)(\.\d+)$';
        tokens = regexp(subfolderName, pattern, 'tokens', 'once');

        if ~isempty(tokens)
            baseName = tokens{1};  % Extract the base name

            % Check if the base name exists in the map
            if isKey(folderGroups, baseName)
                folderGroups(baseName) = [folderGroups(baseName),' ', subfolderName];
            else
                folderGroups(baseName) = [subfolderName];
            end
        end
    end
    
    % Iterate through the folder groups and merge if needed
    mergedCount = 0;
    for baseName = keys(folderGroups)
        folders = folderGroups(baseName{1});
        folders = strsplit(folders, ' ');
        
        if numel(folders) > 1
            file_output = fullfile(datasetPath,subject_name,cta_folder,baseName{1});
            
            if ~exist(file_output, 'dir')
                mkdir(file_output);
            end
            
            % Move files from subfolders 
            for jj = 1:numel(folders)
                file_input = fullfile(datasetPath,subject_name,cta_folder,folders{jj});
                movefile(fullfile(file_input,'*'), file_output);
                rmdir(file_input)
            end

            mergedCount = mergedCount + 1;
            fprintf("Merged subfolder %s in %s\n", baseName{1}, cta_folder)
        end
    end
    
    if mergedCount == 0
%         fprintf("No merging needed\n")
    end
    
    % Fix any remaining extensions
    renameCount = 0;
    dir_cta = dir(fullfile(datasetPath,subject_name,cta_folder));
    for kk = 3:length(dir_cta)  % Start from 3 to skip '.' and '..' entries
        folderName = dir_cta(kk).name;

        % Check if the folder name matches the ".X" format
        pattern = '^(.*)\.(\d+)$';
        tokens = regexp(folderName, pattern, 'tokens', 'once');

        if ~isempty(tokens)
            baseName = tokens{1};
            number = str2double(tokens{2});

            % Check if the number is greater than 0
            if number > 0
                % Rename the folder by removing the ".X" format
                newFolderName = baseName;
                oldFolderPath = fullfile(datasetPath,subject_name,cta_folder,folderName);
                newFolderPath = fullfile(datasetPath,subject_name,cta_folder,newFolderName);

                % Rename the folder
                movefile(oldFolderPath, newFolderPath);
                
                renameCount = renameCount + 1;
                fprintf("Renamed subfolder %s\n", baseName)
            end
        end
    end
    if renameCount == 0
%         fprintf("No renaming needed\n")
    end
    
    
end
if mergedCount == 0 && renameCount == 0
    fprintf("No issues with series folder found.\n")
else
    fprintf("All issues resolved.\n")
end
fprintf("------------------------------------------------------------------\n")

end