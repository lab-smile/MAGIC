function [] = ct_extract(folder_deid,folder_extr,folder_anno)
%% Temporal CT Extraction
% This function is used to find temporal CT data. It is known to be a
% series 3 image using the CT metadata. Each time point for the series 3
% images should include a whole volume. This code sets up the parameters
% required for dicom conversion of the temporal CT data. Below are the
% features of this function.
%
%   - Generates a bash_param.txt file. The file lists the folder paths
%       containing the temporal CT data, unique subject ID, start and stop
%       numbers for the CT data. All dicom images are named with numbers
%       for this particular dataset.
%   - Creates new directories based on found directories. New directories
%       are generated in the output folder mimicking the same structure as
%       the input folder. If temporal data is not found, a "_missing"
%       suffix is appended to the name and will remain empty.
%
%   Kyle See 02/28/23
%   Smart Medical Informatics Learning and Evaluation (SMILE)
%   Biomedical Engineering
%
%   Input:
%       folder_deid  - Path to deidentified folder
%       folder_extr  - Path to extracted folder
%       folder_anno  - Path to annotation folder
%
% INSTRUCTIONS
%   - Change path for folders
% ------------------------------------------------------------------------
%   Notes
%   - There is no current function to deal with missing folders.
%   - The code is robust to overwriting and will skip folders that already
%       exist in the output folder.
%   - The bash param file will be deleted if all folders are skippable.
%       This will also skip the dcm2niix steps in the bash script.
%   - Handles multiple study folders. A second study folder contains a
%       single folder and usually has "IVCON_WO" in the name.
%   - The study folder that has "IVCON_WO" can sometimes have the data
%       instead.
% ------------------------------------------------------------------------
% Changes
% 3/2/23
% - Removed "IVCON_WO" skip. I found one example which contradicts this
%       rule I made. The only folder that contained the data had this
%       string. I switched to just read directories anyways.
% 
% 3/3/23
% - Fixed an issue where series 3 showed up on a bunch of other files.
%       This is circumvented by adding a byte requirement of >20MB.
% 
% 3/8/23
% - Added a new folder. Generates same folder structure as the extracted
%       folders.
% - Changed variable names to folders instead of i/o
% 
% 3/22/23
% - Changed which metadata was read to find temporal CT. Series number was
%       changed to threshold instead of using a fixed number. Image
%       comments were added to exclude sub-adv and stack. Inclusion of
%       other scans does not hurt the integrity of the final output.
% - Fixed an issue where missing folders are generated even when temporal
%       data is found. This resulted in both a missing and data folder.

%% Code
% Testing settings. 
% To test: Comment lines 1 & 217 | Uncomment lines 65-68
% #########################################
% close all; clear; clc;
% folder_deid = './testing_metadata_deid';
% folder_extr = './testing_metadata_extr';
% folder_anno = './testing_metadata_anno';
% #########################################

% Get list of IDs
dir_subj_deid = dir_list(folder_deid);  % Directory deidentified
dir_subj_extr = dir_list(folder_extr); % Directory extracted

% Check for and delete MATCHES between deidentified and extracted directories
% Loop in reverse order in extract directory
for m1 = length(dir_subj_extr):-1:1

    % Grab name and strip _missing suffix
    filename = dir_subj_extr(m1).name;
    if contains(filename,'_missing')
        filename = extractBefore(filename,'_missing');
    end

    % Find the location of existing folder in deid
    idc = [];
    for m2 = length(dir_subj_deid):-1:1
        if contains(dir_subj_deid(m2).name,filename)
            idc = m2;
        end
    end

    % Remove deid folder if found in extract folder
    dir_subj_deid(idc) = [];
end

%-------------------------------------------------------------------------
% No parfor. Loops are not independent. Write into same bash_param.txt
%-------------------------------------------------------------------------

% Start loops only if deid directories are still present
if ~isempty(dir_subj_deid)

    % Start with a fresh bash_param.txt file.
    if exist(fullfile('bash_param.txt'), 'file')
        filepath = fullfile('bash_param.txt');
        delete(filepath)
    end

    % Loop through each subject in deid.
    for i = 1:length(dir_subj_deid)

        % cd into subject folder
        dir_study = dir_list(fullfile(folder_deid,dir_subj_deid(i).name));

        % Generate missing folder only once all study folders are checked
        missing_counter = 0; % A check for missing data
        
        % Loop through each study folder.
        for s1 = 1:length(dir_study)

            % Loop through only if directory
            if dir_study(s1).isdir

                % cd into study folder
                dir_series = dir_list(fullfile(folder_deid,dir_subj_deid(i).name,dir_study(s1).name));

                % Reset shell parameters per subject
                shell_inputpath = [];
                shell_numbers = [];
                shell_start = [];
                shell_stop = [];

                % Loop through each series folder.
                for j = 1:length(dir_series)

                    % cd into series folder
                    dir_images = dir_list(fullfile(dir_series(j).folder,dir_series(j).name));

                    % Loop through each dicom image.
                    for k = 1:length(dir_images)
                        info = [];
                        try
                            info = dicominfo(fullfile(dir_images(k).folder,dir_images(k).name));
                            % Looking for series 3 and byte req. >30MB or 3,000,000 bytes
                            if info.SeriesNumber == 3 && dir_images(k).bytes > 30000000
                                % Save path and numbers
                                shell_inputpath = dir_images(k).folder;
                                shell_numbers = [shell_numbers; str2double(extractBefore(dir_images(k).name,'.dcm'))];
                            end
                        catch % To prevent the script from crashing if info can't be read
                        end

                    end
                end

                % Set shell start and stop
                if exist(shell_inputpath,'dir') % If found, print parameters
                    shell_start = min(shell_numbers);
                    shell_stop = max(shell_numbers);

                    % Check for double series 3. Expected folder does not exist because
                    % of previous check btwn deid and extract
                    if ~exist(fullfile(folder_extr,dir_subj_deid(i).name),'dir')
                        mkdir(fullfile(folder_extr,dir_subj_deid(i).name))
                        mkdir(fullfile(folder_anno,dir_subj_deid(i).name))
                    else
                        fprintf("Possible second folder containing series 3 for: %s",dir_subj_deid(i).name)
                    end

                    % Write into the bash_param text file
                    bash_param_path = fullfile('bash_param.txt');
                    fid = fopen(bash_param_path,'a+');
                    fprintf(fid,"%s\n%s\n%d\n%d\n",shell_inputpath, dir_subj_deid(i).name, shell_start, shell_stop);
                    fclose(fid);
                    fprintf("Parameters recorded for %s\n",dir_subj_deid(i).name)
                    
                    missing_counter = missing_counter + 1;   
                end
            end
            
        end

        % Generate missing folder ONLY if no temporal data was found
        if missing_counter == 0
            fprintf("DID NOT FIND FOR %s\n",dir_subj_deid(i).name)
            mkdir(fullfile(folder_extr,[dir_subj_deid(i).name,'_missing']))
            mkdir(fullfile(folder_anno,[dir_subj_deid(i).name,'_missing']))
        end
        
    end
else
    % If all folders exist, delete bash_param.txt for the shell script
    fprintf("All folders exist in extract and deid.\n")
    filepath = fullfile('bash_param.txt');
    delete(filepath)
end

%% Local Functions
% Given an input path, an output directory list will be output. Returns a
% directory list without dot notations.
%   Input:  'C:\Users\Kyu\Desktop\AFRL\processed_data\CAPS\subjects'
%   Output: Structure of the subjects folder

    function output_dir = dir_list(input_path)
        dir_input = dir(input_path);
        output_dir = dir_input(~ismember({dir_input.name},{'.','..'}));
    end
end