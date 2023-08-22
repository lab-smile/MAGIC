%% Parallel DICOM Dataset Deidentification and Directory Organization
%----------------------------------------
% Created by Garrett Fullerton
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
% Dr. Ruogu Fang
% 8/28/2020
%----------------------------------------
% Last Updated: 8/28/2020 by GF
% Main Structure
%
% This script de-identifies batch patient DICOM studies much more quickly
% than the original de-identification script, but there is a loss of
% functionality in generating a value such as the visitNumber.
% The visit number has been designated as '1' for all subjects. 
% Additionally, the command window will no longer display the file number
% that is being worked on. Feel free to adjust the output to the command
% window however you see fit.
% 
% To remove this: 
% 1) Press Ctrl + F and search: disp(k)
% 2) Comment this line out
%

%% Settings
clear; close all; clc;
warning off;

% Path to deidentification helper functions
p_deident = genpath('C:/Users/gfullerton/Documents/REU/REU-main/scripts/utilities/');
addpath(p_deident);

% Edit datasetPath variable to the directory containing all patients
%datasetPath = 'C:/Users/gfullerton/Documents/REU/testing/';
%outputPath = 'C:/Users/gfullerton/Documents/REU/testing_output/';
datasetPath = 'E:/IRB201800011-Fang/';
outputPath = 'E:/ct_organized/';

if ~exist(outputPath,'dir'),mkdir(outputPath); end

% Edit path to Excel and CSV files - Do not create the files beforehand
datasetSummaryFilePath = fullfile(outputPath,'data_summary.xlsx'); % Excel file
csvFilePath = fullfile(outputPath,'data_summary.csv'); % CSV file
% datasetSummaryFilePath = 'D:/Garrett/summary2/data_summary.xlsx'; % Excel file
% csvFilePath = 'D:/Garrett/summary2/data_summary.csv'; % CSV file

% UID root number
UID_root = '1.2.826.1.1.3680043.2.103';

% Set cutoff age//Anything above cutoff age is PHI
age_PHI_cutoff = 90;

% Number of patients that have already been deidentified
% Ex: If processing an entirely new batch,set patientNum = 0
numProcessed = 0;

% Number of weeks to shift study date forward
dateshift_val = 12;

% Keywords in series description to check for different modalities
NCCT_keywords = {'W-O','WITHOUT','WO','NCCT','NON CON','NON-CON','NON_CON'};
CTP_keywords = {'PERFUSION','CTP','4D','DYNAMIC','CBP'};
CECT_keywords = {'W-C','WITH','WC','CE','CECT'};

%% Process Data

% Initializing variables
subDirs = dir(datasetPath);
iStart = 0;

alphabet = {'A','B','C','D','E','F','G','H','I','J','K','L',...
    'M','N','O','P','Q','R','S','T','U','V','W','X',...
    'Y','Z','0','1','2','3','4','5','6','7','8','9'};

emptyFolders = 0;
birthYear = '';

Summary = struct;


% Removing empty directories
for i = 3:length(subDirs)
    try
        rmdir(fullfile(datasetPath,'/',subDirs(i).name));
    catch
    end
end

subDirs = dir(datasetPath);
subDirs = di_fixDir(subDirs);
subDirLength = length(subDirs);

curDirCount = 0;

%% Processing patients
parfor i = 1:subDirLength
    warning off;
    fprintf('--------------------------------------Starting with Directory %i of %i-----------------------------------\n',i,subDirLength);
    
    % Initializing variables
    curDir = subDirs(i);
    GType = 0;
    %series_UIDs = containers.Map;
    %gen_study_UID = true;
    curDirCount = 1;  
    
    
    d = dir(fullfile(curDir.folder,curDir.name));
    isub = [d(:).isdir];
    nameFolds = {d(isub).name}';
    if any(strcmp(nameFolds,'IMAGES'))
        GType = 1;
    end

    
    % Calculating patientNum, assign visitNum
    patientNum = numProcessed + i;
    visitNum = '1';
    
%     % Generate new accession number for each new patient
%     alphabetIndexes = randi(length(alphabet),1,8);
%     newAccessionNumber = cell2mat(alphabet(alphabetIndexes));
%     
%     % Add patient info to summary table
%     Summary(i).OriginalFileName = curDir.name;
%     Summary(i).PatientID = patientNum;
%     Summary(i).AccessionNumber = newAccessionNumber;
%     Summary(i).VisitNumber = str2double(visitNum);
%     
    
    % Iterate through patient DICOM files
    if GType == 1
        files = dir(fullfile(datasetPath,curDir.name,'IMAGES'));
    else
        files = dir(fullfile(datasetPath,curDir.name));
    end
    
    files = di_fixDir(files);
    
    if(length(files) > 1)
        for k = 1:length(files)
            disp(k);
            
            % Path to individual files
            if GType == 1
                filepath = fullfile(datasetPath,curDir.name,'IMAGES',files(k).name);
            else
                filepath = fullfile(datasetPath,curDir.name,files(k).name);
            end
            
            % Read DICOM metadata from individual files
            try
                fileInfo = dicominfo(filepath,'UseDictionaryVR',true);
                % fprintf('%s:',fileInfo.StudyDate);
            catch
                fileInfo = dicominfo(filepath);
            end
            
            try
                fileImage = dicomread(filepath);
            catch
            end
            newID = fileInfo.PatientID;
%             fileImage_store = fileImage;
%             fileInfo_store = fileInfo;
            
            % Create a new patient ID
%             newID = strcat(num2str(patientNum,'%06.f'),num2str(str2double(visitNum),'%02.f'));
            
            
            % Create variables to sort folders
            [studyDescription,seriesDescription] = di_getDescription(fileInfo,newID);
            [studyDescription,seriesDescription] = di_fixDescription(studyDescription,seriesDescription);
            
%             % Shift study date
%             curDate = datetime(str2double(fileInfo.StudyDate),'ConvertFrom','yyyymmdd');
%             newDate = dateshift(curDate,'end','week',dateshift_val);
%             newDate = num2str(yyyymmdd(newDate));
%             
%             Summary(i).OriginalStudyDate = yyyymmdd(curDate);
%             Summary(i).AdjustedStudyDate = str2double(newDate);
%             fileInfo.StudyDate = newDate;
%             fileInfo.SeriesDate = newDate;
            
%             % Generate and assign new UIDs
%             % Study Instance UID
%             if gen_study_UID
%                 newStudyUID = di_makeUID(fileInfo.StudyDate,fileInfo.StudyTime,UID_root);
%                 gen_study_UID = false;
%             end
%             fileInfo.(dicomlookup('0020','000D')) = newStudyUID;
%             
%             % Series Instance UID
%             if series_UIDs.isKey(seriesDescription)
%                 fileInfo.(dicomlookup('0020','000E')) = series_UIDs(seriesDescription);
%             else
%                 series_UIDs(seriesDescription) = di_makeUID(fileInfo.StudyDate,fileInfo.StudyTime,UID_root);
%                 fileInfo.(dicomlookup('0020','000E')) = series_UIDs(seriesDescription);
%             end
%             
%             newSOPUID = di_makeUID(fileInfo.StudyDate,fileInfo.StudyTime,UID_root);
%             fileInfo.(dicomlookup('0008','0018')) = newSOPUID; % SOP Instance UID
%             fileInfo.(dicomlookup('0002','0003')) = newSOPUID; % Media Storage SOP Instance UID
%             
%             fileInfo.(dicomlookup('0020','0052')) = di_makeUID(fileInfo.StudyDate,fileInfo.StudyTime,UID_root); % Frame of Reference UID
%             
%             if isfield(fileInfo,dicomlookup('0008','1111'))
%                 newRefSOPUID = di_makeUID(fileInfo.StudyDate,fileInfo.StudyTime,UID_root);
%                 fileInfo.(dicomlookup('0008','1111')).Item_1.(dicomlookup('0008','1155')) = newRefSOPUID; % Referenced SOP Instance UID
%             end
            
%             % Check if RGB image is read as grayscale & reorder pixel data
%             if isfield(fileInfo,dicomlookup('0028','0010')) && isfield(fileInfo,dicomlookup('0028','0011'))
%                 if (fileInfo.Rows ~= size(fileImage,1)) || (fileInfo.Columns ~= size(fileImage,2))
%                     img_len = size(fileImage,2);
%                     new_img = uint8(zeros(fileInfo.Rows,fileInfo.Columns,3));
%                     new_img(:,:,1) = fileImage(:,mod(1:img_len,3)==1); % Extract RGB channels
%                     new_img(:,:,2) = fileImage(:,mod(1:img_len,3)==2);
%                     new_img(:,:,3) = fileImage(:,mod(1:img_len,3)==0);
%                     
%                     fileImage = new_img;
%                 end
%             end
%             
%             % Check if the file is a CT perfusion map
%             % If so,remove the annotated PHI on the image
%             if isfield(fileInfo,dicomlookup('0008','0008')) % Image Type
%                 % Check for perfusion map image type
%                 % First condition includes PMs and AIF/VOF curves
%                 % Second filters out AIF/VOF curves,leaving just PMs
%                 if strcmpi(fileInfo.(dicomlookup('0008','0008')),'DERIVED\SECONDARY\') && ~isfield(fileInfo,dicomlookup('0008','0005'))
%                     fileImage = di_rmPerfMapPHI(fileImage);
%                 end
%             end
            
%             % Deidentify/Edit fields
%             % See  https://www.dicomlibrary.com/dicom/dicom-tags/  for list of all dicom tags
%             % See https://dicom.innolitics.com/ciods/ct-image/ for dicom tags and sequences in CT scans
%             fileInfo.PatientID = newID;
%             fileInfo.PatientName = newID;
%             fileInfo.StudyID = newAccessionNumber;
%             fileInfo.AccessionNumber = newAccessionNumber;
%             
%             [birthYear,age_PHI_check] = di_getAge(fileInfo,age_PHI_cutoff);
%             fileInfo = di_fixAge(fileInfo,age_PHI_cutoff,age_PHI_check,birthYear);
%             
            
%             % Store the original Implementation Class UID and Version Name
%             ImClassStore = char(fileInfo.(dicomlookup('0002','0012'))); % Original Implemenation Class UID
%             ImVerStore = char(fileInfo.(dicomlookup('0002','0013'))); % Original Implementation Version Name
%             
%             
%             % Remove and edit DICOM metadata fields
%             fileInfo = di_rmMetaPHI(fileInfo);
%             fileInfo = di_adjustMetaPHI(fileInfo,newID,birthYear,newAccessionNumber,newDate,newStudyUID);
%             
%             % Deidentify radiology report
%             try
%                 title = fileInfo.ConceptNameCodeSequence.Item_1.CodeMeaning;
%                 if strcmpi(title,'RADIOLOGY REPORT')
%                     fileInfo = di_rmRadReportPHI(fileInfo,newDate,newStudyUID);
%                 end
%             catch
%             end
%             
%             % Deidentify dose summary
%             try
%                 if contains(upper(fileInfo.SeriesDescription),'SUMMARY') && ~contains(upper(fileInfo.SeriesDescription),'RAPID')
%                     fileImage = di_blackoutImage(fileInfo.Filename,fileInfo.InstanceNumber,GType,age_PHI_check);
%                 end
%             catch
%             end
            
%             % Deidentify X-ray radiation dose report
%             fileInfo = di_adjustDoseRptPHI(fileInfo,UID_root);
%             
%             % Check if if series is a specific scanning modality
%             if contains(upper(seriesDescription),NCCT_keywords),Summary(i).NCCT = true; end
%             if contains(upper(seriesDescription),CTP_keywords),Summary(i).CTP = true; end
%             if contains(upper(seriesDescription),CECT_keywords),Summary(i).CECT = true; end
%             
            
            % Create folder structure
            %newCurDir = strcat(newID,'_',birthYear);
            if not(isfolder(strcat(outputPath,curDir.name)))
                mkdir(strcat(outputPath,curDir.name))
            end
            
            % The main folder
            %mainDirPath = strcat(studyDescription,fileInfo.StudyID,'_',fileInfo.StudyDate(1:4),'0101');
            mainDirPath = strcat(studyDescription,'_',fileInfo.StudyID);
            mainDirList = split(mainDirPath,' ');
            mainDir = join(mainDirList,'_');
            
            % The subfolder
            subDirList = split(seriesDescription,' ');
            subDirList = subDirList(~cellfun('isempty',subDirList));
            subDirString = join(subDirList,'_');
            subDir = replace(subDirString,'/','-');
            
            
            % Write original Implementation Class & Version to private fields
%             fileInfo = di_writePriv(fileInfo,ImClassStore,ImVerStore);
            
            studyPath = fullfile(outputPath,curDir.name,char(mainDir));
            seriesPath = fullfile(studyPath,char(subDir));
            %filePath = fullfile(seriesPath,num2str(k));
            % Sorting into subdirectories
            if ~exist(studyPath,'dir'), mkdir(studyPath); end
            if ~exist(seriesPath,'dir'), mkdir(seriesPath); end

            %di_saveDICOM(fileImage_store,fileInfo_store,filePath);
            copyfile(filepath,seriesPath);
            %fprintf('Done copying %s',filepath);
            emptyFolders = emptyFolders+1;
        end
        
        fprintf('--------------------------------------Done with Directory %i of %i-----------------------------------\n',i,subDirLength)
    end
end


% Remove folders and files that have been deidentified
% if remove_processed_folders
%     rmdir(datasetPath)
%     fprintf('--------------------------------------Done Deleting Directories -------------------------------\n');
% end

% Fill in false logicals in summary struct
% Reorder summary and convert it to a table
% CTP_inds_false = find(cellfun(@isempty,{Summary.CTP}));
% CECT_inds_false = find(cellfun(@isempty,{Summary.CECT}));
% NCCT_inds_false = find(cellfun(@isempty,{Summary.NCCT}));
% 
% for i = 1:numel(CTP_inds_false), Summary(CTP_inds_false(i)).CTP = false; end
% for i = 1:numel(CECT_inds_false), Summary(CECT_inds_false(i)).CECT = false; end
% for i = 1:numel(NCCT_inds_false), Summary(NCCT_inds_false(i)).NCCT = false; end
% 
% Summary = struct2table(Summary);
% [~,sort_inds] = sort(Summary.PatientID);
% Summary = Summary(sort_inds,:);

% Write summary and CSV files
%writetable(Summary,datasetSummaryFilePath)
%writetable(Summary,csvFilePath,'Delimiter',',')
fprintf('--------------------------------------Done with Everything-------------------------------------\n')
