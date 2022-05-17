%% Match CTP Map Slices
%----------------------------------------
% Created by Garrett Fullerton
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
% Dr. Ruogu Fang
% 10/18/2020
%----------------------------------------

% Last Updated: SES
% modified for temporal data


%outline
%index all the NCCT slices and get a list of the z-locations
%get a list of all the maps files
%for ONE modality of the maps files (length/4)
    %find the closest NCCT
    %find the matching slices from the other modalities
    %segment tissue from NCCT and apply mask to CTP slices
    %name everything the same and save everything
    %increment slice idx
%done!

%% Main function

clc; clear; close all; warning off;

datasetPath = 'E:/DICOM_RAPID_Organized/';
outputPath = 'C:\Users\skato1\Desktop\slicematch';

%% Add utilitie functions to the path
current_directory = pwd();
cd("../utilities")
utilities = pwd();
cd(current_directory)

p_deident = genpath(utilities);
addpath(p_deident);
addpath("C:\Users\skato1\Desktop\REU\scripts");

allMapping = importdata('id_mapping.xlsx');
allMapping = string(allMapping);

testPatients = ["00020101", '00020201','00020301','00020401','00020501','00020601','00020701','00020801','00021001','00021101','00021201','00021301','00021401','00021501','00021601','00021701','00021801','00022001','00022101','00022201','00022301','00021301','00021901','00027201','00030101','00030601','00031801','00032401','00035101','00037601','00039701','00040801','00048101','00048701','00051701','00057801','00058001','00058301','00059301','00061401','00059701','00068001','00020901','00022701','00023901','00024601','00027101','00028101','00037301','00040501','00041601','00041401','00042301','00043801','00045501','00052801','00053401','00054901','00055201','00060901','00062201','00065001','00065101'];

slice_threshold = 2; % maximum distance (mm) between slices
% prevents incorrect matching if series 1 starts way below the start of series 2
% dsize = 7; % disk size, used in NCCT tissue segmentation
% ub = 200; % upper boundary, used in NCCT tissue segmentation
startNum=1; % patient start number

% %--

if ~exist(fullfile(outputPath),'dir'), mkdir(fullfile(outputPath)); end
subjects = dir(datasetPath);

parfor j = startNum+2:length(subjects)
    subject = subjects(j);
    subject_name = subject.name;
    
    mapped_folder = allMapping(find(allMapping == subject_name) + length(allMapping));
    if not(ismember(mapped_folder, testPatients))
        continue;
    end
    
    subjectoverallsavePath = fullfile(outputPath, subject_name);
    if ~exist(subjectoverallsavePath,'dir'), mkdir(subjectoverallsavePath); end
       
    [~,~,ext] = fileparts(fullfile(subject.folder,subject_name));
    if strcmp(ext,'.csv') || strcmp(ext,'.xlsx'), continue; end
    if strcmp(subject_name(1),'.'), continue; end
    fprintf('Processing subject %s\n',subject_name);
    
    study_name = dir(fullfile(subject.folder,subject.name));
    study_name = study_name(3);
    series_all = dir(fullfile(study_name.folder,study_name.name));
    series_names = {series_all.name};
    series_name = study_name.name;
    
    CBP4D_zcoords = containers.Map('KeyType','double','ValueType','char');
    MIP_zcoords = containers.Map('KeyType','double','ValueType','char');

    % Indexing by finding keywords in filename
    CBP4D_idx = contains(series_names, 'Vol', 'IgnoreCase', true);
    CBP4D_idx = or(CBP4D_idx,contains(series_names,'DYNAMIC','IgnoreCase',true));
    CBP4D_idx = and(CBP4D_idx, contains(series_names, '05', 'IgnoreCase', true));
%     05_CE_4DVol_4D_CBP_Head_3
%     Perfusion_05_CE_Perfusion_Head_4D_CBP_DYNAMIC_2
    
    MIP_idx = contains(series_names, 'AxMIP', 'IgnoreCase', true);
    MIP_idx = and(MIP_idx, contains(series_names, '100', 'IgnoreCase', true));
%     100_CE_AxMIP_4D_CBP_Head_14
%     Perfusion_10000_CE_AxMIP_Head_4D_CBP_STACKAxMIP3_13  
    
    CBP4D_series = []; MIP_series = [];
    if ~any(CBP4D_idx)
        fprintf('Cannot locate CBP4D series for subject %s. Please select the correct directory.\n',subject.name);
        CBP4D_selpath = uigetdir(fullfile(study_name.folder,study_name.name),'CBP4D Folder');
        CBP4D_files = dir(CBP4D_selpath);
    else
        CBP4D_series = series_names(CBP4D_idx);
        CBP4D_series_name = string(CBP4D_series(1));
        CBP4D_files = dir(fullfile(study_name.folder,study_name.name,CBP4D_series_name,'*.dcm'));
    end
    
    if ~any(MIP_idx)
        fprintf('Cannot locate MIP series for subject %s. Please select the correct directory.\n',subject.name);
        MIP_selpath = uigetdir(fullfile(study_name.folder,study_name.name),'MIP Folder');
        MIP_files = dir(MIP_selpath);
    else
        MIP_series = series_names(MIP_idx);
        MIP_series_name = string(MIP_series(1));
        MIP_selpath = fullfile(study_name.folder,study_name.name,MIP_series_name);
        MIP_files = dir(fullfile(study_name.folder,study_name.name,MIP_series_name,'*.dcm'));
    end
    
    % Create map of all CBP4D z-locations: same across temporal
    % % for each output path
    CBP4DsavespatialPath = fullfile(outputPath, 'CBP4D_spatial');
    if ~exist(CBP4DsavespatialPath,'dir'), mkdir(CBP4DsavespatialPath); end
    
%     for i = 1:length(CBP4D_files)
%         CBP4D_file = CBP4D_files(i);
        CBP4D_file = CBP4D_files(11);
%         if strcmp(CBP4D_file.name(1),'.'),continue;end
        CBP4D_filepath = fullfile(CBP4D_file.folder,CBP4D_file.name);
        CBP4D_dicom = squeeze(dicomread(CBP4D_filepath));
        CBP4D_info = dicominfo(CBP4D_filepath);
        CBPfields = fieldnames(CBP4D_info.PerFrameFunctionalGroupsSequence);
        for jj = 1 : numel(CBPfields)
          patient_pos = CBP4D_info.PerFrameFunctionalGroupsSequence.(CBPfields{jj}).PlanePositionSequence.Item_1.ImagePositionPatient;
%             patient_pos = CBP4D_info.PerFrameFunctionalGroupsSequence.Item_160.PlanePositionSequence.Item_1.ImagePositionPatient;
          z_coord = patient_pos(3);
          CBP4D_dicom_save = CBP4D_dicom(:,:,jj);
          [a,b,c] = fileparts(CBP4D_file.name);
          name = sprintf('subject-%s_%s_slice-%d%s', subject_name, b, jj,c);
          
          subjectsavePath = fullfile(CBP4DsavespatialPath, subject_name);
          if ~exist(subjectsavePath,'dir'), mkdir(subjectsavePath); end
          
          dicomwrite(CBP4D_dicom_save, fullfile(subjectsavePath, name));
          CBP4D_zcoords(z_coord) = fullfile(subjectsavePath, name);
        end
%     end
    
    % get map of all MIP z-locations
    for i = 1:length(MIP_files)
        MIP_file = MIP_files(i);
        if strcmp(MIP_file.name(1),'.'),continue;end
        MIP_filepath = fullfile(MIP_file.folder,MIP_file.name);
        MIP_info = dicominfo(MIP_filepath);
        MIP_img = dicomread(MIP_filepath);
        coords = MIP_info.ImagePositionPatient;
        z_coord = coords(3);
        MIP_zcoords(z_coord) = MIP_filepath;
    end
    
    CBP4D_zs = cell2mat(keys(CBP4D_zcoords));
    MIP_zs = cell2mat(keys(MIP_zcoords));
    slice_num = 1;
    
    AxMIP_names = {};
    CBP4D_names = {};
    
    % go through each map (one modality only in loop)
    %for i = 1:length(rCBV_zcoords)
%     for i = 4:length(rCBV_zcoords)-3 %this was done just so i only select the middle slices of the series
    for i = 1:length(MIP_zcoords)
%         rCBV_z = rCBV_zs(i);
%         rCBV_img = getCorrectImage(rCBV_zcoords,rCBV_z);
        MIP_z = MIP_zs(i);
        MIP_name = MIP_zcoords(MIP_z);
        MIP_img = dicomread(MIP_name); MIP_info = dicominfo(MIP_name);
%         MIP_img = getCorrectImage(MIP_zcoords, MIP_z);
        
        [closest_val,idx] = min(abs(CBP4D_zs-MIP_z));
        closest_val = closest_val(1);
        if closest_val >= slice_threshold, continue; end
        CBP4D_z = CBP4D_zs(idx);
        CBP4D_name = CBP4D_zcoords(CBP4D_z);
        CBP4D_img = dicomread(CBP4D_name); CBP4D_info = dicominfo(CBP4D_name);
%         CBP4D_img = convert_DICOM_to_uint8(CBP4D_img,CBP4D_info); % converting DICOM to uint8

%         saveName = strcat(subject_name(1:8),'_',num2str(slice_num),'.bmp');
        slicesavePath = fullfile(subjectoverallsavePath, num2str(slice_num));
        if ~exist(slicesavePath,'dir'), mkdir(slicesavePath); end
%         if all(CBP4D_img(:)==0)
%             continue;
%         elseif all(MIP_img_fin(:)==0)
%             continue;
%         end
        
        %save_check = input('Keep this file? (y/n): ','s');
        save_check = 'y';
        %close all;
        if contains(save_check,'y') || contains(save_check,'Y')
%             mask_fin = (MTT_img ~= 0);
%             mask_fin = (CBP4D_img ~= 0);

            % call parsave to be able to write images inside a parfor loop
            % not required, you can just use imwrite or dicomwrite or
            % whatever instead
            % parfor loops just aren't a fan of directly writing a file,
            % it works better to call an external function that writes your
            % file instead
            [MIP_a, MIP_b, MIP_c] = fileparts(MIP_name);
            name_MIP = sprintf('subject-%s_%s_AxMIP%s', subject_name, MIP_b, MIP_c);
            %parsave(fullfile(slicesavePath, strcat(MIP_b,MIP_c)), MIP_img);
            finalMIP = fullfile(slicesavePath, name_MIP);
            parsave(finalMIP, MIP_img);
            AxMIP_names{end+1,1} = finalMIP;
            
            [CBP4D_a, CBP4D_b, CBP4D_c] = fileparts(CBP4D_name);
            finalCBP4D = fullfile(slicesavePath, strcat(CBP4D_b,CBP4D_c));
            parsave(finalCBP4D, CBP4D_img);
            CBP4D_names{end+1,1} = finalCBP4D;
            
            % just a funky little figure
            %saveas(f,fullfile('C:/Users/gfullerton/Desktop/pics_new/',strcat(saveName,'.png')));
            close all;
            slice_num=slice_num+1;
        end
    end
    
    t = table(AxMIP_names, CBP4D_names);
    writetable(t, fullfile(subjectoverallsavePath, 'list.csv'));
    
    fprintf('----------Finished with subject %s----------\n',subject_name);
end
disp('----------Finished with all----------');
