%% Match NCCT and CTP Perfusion Map Slices
%----------------------------------------
% Created by Garrett Fullerton
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
% Dr. Ruogu Fang
% 10/18/2020
%----------------------------------------
% Last Updated: 11/1/2020 by GF
% Create v4.
% add gui and update selection methods
%
% This function requires that the dataset contain axial MIP, NCCT, and
% perfusion map data.

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

%% Main function

clc; clear; close all; warning off;

%datasetPath = 'C:/Users/gfullerton/Documents/REU/slicematch_testing/input/';
%outputPath = 'C:/Users/gfullerton/Documents/REU/slicematch_testing/output4/';
datasetPath = 'E:/IRB_RAPID_DEIDENTIFIED/';
outputPath = 'C:/Users/gfullerton/Documents/REU/slicematch_rapid_stack_offset4/';

addpath(genpath('C:/Users/gfullerton/Documents/REU/REU-main-2/REU/scripts/'));

load('RAPID_U.mat');

offset = 4; % integer greater than 0
slice_threshold = 2;
dsize = 7;
ub = 200;
startNum=10;

load('C:/Users/gfullerton/Desktop/RAPIDModalities.mat');

%--

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

subjects = dir(datasetPath);

for j = startNum+2:length(subjects)
    subject = subjects(j);
    subject_name = subject.name;
       
    [~,~,ext] = fileparts(fullfile(subject.folder,subject_name));
    if strcmp(ext,'.csv') || strcmp(ext,'.xlsx'), continue; end
    if strcmp(subject_name(1),'.'), continue; end
    fprintf('Processing subject %s\n',subject_name);
    
    study_name = dir(fullfile(subject.folder,subject.name));
    study_name = study_name(3);
    series_all = dir(fullfile(study_name.folder,study_name.name));
    series_names = {series_all.name};
    
    NCCT_zcoords = containers.Map('KeyType','double','ValueType','char');
    rCBV_zcoords = containers.Map('KeyType','double','ValueType','char');
    rCBF_zcoords = containers.Map('KeyType','double','ValueType','char');
    MTT_zcoords = containers.Map('KeyType','double','ValueType','char');
    TTP_zcoords = containers.Map('KeyType','double','ValueType','char');
    
    % Indexing
    NCCT_idx = contains(series_names,'without','IgnoreCase',true);
    NCCT_idx = or(NCCT_idx,contains(series_names,'W-O','IgnoreCase',true));
    NCCT_idx = or(NCCT_idx,contains(series_names,'NCCT','IgnoreCase',true));
    NCCT_idx = or(NCCT_idx,contains(series_names,'NON-CON','IgnoreCase',true));
    NCCT_idx = or(NCCT_idx,contains(series_names,'NON_CON','IgnoreCase',true));
    NCCT_idx = and(NCCT_idx,~contains(series_names,'bone','IgnoreCase',true));
    
    maps_idx = contains(series_names,'rapid','IgnoreCase',true);
    maps_idx = and(maps_idx,contains(series_names,'maps','IgnoreCase',true));
    
    NCCT_series = []; maps_series = [];
    if ~any(NCCT_idx)
        fprintf('Cannot locate NCCT series for subject %s. Please select the correct directory.\n',subject.name);
        NCCT_selpath = uigetdir(fullfile(study_name.folder,study_name.name),'NCCT Folder');
        NCCT_files = dir(NCCT_selpath);
    else
        NCCT_series = series_names(NCCT_idx);
        NCCT_series_name = string(NCCT_series(1));
        NCCT_files = dir(fullfile(study_name.folder,study_name.name,NCCT_series_name,'*.dcm'));
    end
    
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
    for i = 1:length(NCCT_files)
        NCCT_file = NCCT_files(i);
        if strcmp(NCCT_file.name(1),'.'),continue;end
        NCCT_filepath = fullfile(NCCT_file.folder,NCCT_file.name);
        NCCT_info = dicominfo(NCCT_filepath);
        coords = NCCT_info.ImagePositionPatient;
        z_coord = coords(3);
        NCCT_zcoords(z_coord) = NCCT_filepath;
    end
    
    % get map of all map z-locations
    for i = 1:length(maps_files)
        map_file = maps_files(i);
        if strcmp(NCCT_file.name(1),'.'),continue;end
        map_filepath = fullfile(map_file.folder,map_file.name);
        map_info = dicominfo(map_filepath);
        map_img = dicomread(map_filepath);
        coords = map_info.ImagePositionPatient;
        z_coord = coords(3);
        modality = identifyRAPIDModality(map_img, TTP_test, rCBV_test, rCBF_test, MTT_test);
        
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
    
    NCCT_zs = cell2mat(keys(NCCT_zcoords));
    rCBV_zs = cell2mat(keys(rCBV_zcoords));
    rCBF_zs = cell2mat(keys(rCBF_zcoords));
    MTT_zs = cell2mat(keys(MTT_zcoords));
    TTP_zs = cell2mat(keys(TTP_zcoords));
    slice_num = 1;
    
    % go through each map (one modality only in loop)
    %for i = 1:length(rCBV_zcoords)
    for i = 4:length(rCBV_zcoords)-3
        rCBV_z = rCBV_zs(i);
        
        rCBV_img = getCorrectImage(rCBV_zcoords,rCBV_z);
        
        [closest_val,idx] = min(abs(rCBF_zs-rCBV_z));
        closest_val = closest_val(1);        
        if closest_val >= slice_threshold, continue; end
        rCBF_z = rCBF_zs(idx);
        rCBF_img = getCorrectImage(rCBF_zcoords,rCBF_z);
        
        [closest_val,idx] = min(abs(MTT_zs-rCBV_z));
        closest_val = closest_val(1);
        if closest_val >= slice_threshold, continue; end
        MTT_z = MTT_zs(idx);
        MTT_img = getCorrectImage(MTT_zcoords,MTT_z);
        
        [closest_val,idx] = min(abs(TTP_zs-rCBV_z));
        closest_val = closest_val(1);
        if closest_val >= slice_threshold, continue; end
        TTP_z = TTP_zs(idx);
        TTP_img = getCorrectImage(TTP_zcoords,TTP_z);
        
        [closest_val,idx] = min(abs(NCCT_zs-rCBV_z));
        closest_val = closest_val(1);
        %if closest_val >= slice_threshold, continue; end
        
        NCCT_z_1 = NCCT_zs(idx-offset);
        NCCT_z_2 = NCCT_zs(idx);
        NCCT_z_3 = NCCT_zs(idx+offset);
        NCCT_name_1 = NCCT_zcoords(NCCT_z_1);
        NCCT_name_2 = NCCT_zcoords(NCCT_z_2);
        NCCT_name_3 = NCCT_zcoords(NCCT_z_3);
        NCCT_img_1 = dicomread(NCCT_name_1); NCCT_info_1 = dicominfo(NCCT_name_1);
        NCCT_img_1 = convert_DICOM_to_uint8(NCCT_img_1,NCCT_info_1);
        NCCT_img_2 = dicomread(NCCT_name_2); NCCT_info_2 = dicominfo(NCCT_name_2);
        NCCT_img_2 = convert_DICOM_to_uint8(NCCT_img_2,NCCT_info_2);
        NCCT_img_3 = dicomread(NCCT_name_3); NCCT_info_3 = dicominfo(NCCT_name_3);
        NCCT_img_3 = convert_DICOM_to_uint8(NCCT_img_3,NCCT_info_3);
        
%         figure; subplot(121);imshow(NCCT_img);
        NCCT_img_store_1 = NCCT_img_1;
        NCCT_mask_1 = pct_brainMask_noEyes(NCCT_img_1, 0, ub, dsize);
        NCCT_img_1(~NCCT_mask_1) = 0;
        NCCT_mask2_1 = pct_brainMask_noEyes(NCCT_img_1, 0, ub, 4);
        NCCT_img_1(~NCCT_mask2_1) = 0;
        
        NCCT_img_store_2 = NCCT_img_2;
        NCCT_mask_2 = pct_brainMask_noEyes(NCCT_img_2, 0, ub, dsize);
        NCCT_img_2(~NCCT_mask_2) = 0;
        NCCT_mask2_2 = pct_brainMask_noEyes(NCCT_img_2, 0, ub, 4);
        NCCT_img_2(~NCCT_mask2_2) = 0;
        
        NCCT_img_store_3 = NCCT_img_3;
        NCCT_mask_3 = pct_brainMask_noEyes(NCCT_img_3, 0, ub, dsize);
        NCCT_img_3(~NCCT_mask_3) = 0;
        NCCT_mask2_3 = pct_brainMask_noEyes(NCCT_img_3, 0, ub, 4);
        NCCT_img_3(~NCCT_mask2_3) = 0;
%         subplot(122); imshow(NCCT_img);
        
        % Reshape the NCCT image to have the same dimensions as perfusion
        NCCT_img_1 = imresize(NCCT_img_1,[256 256]);
        NCCT_img_2 = imresize(NCCT_img_2,[256 256]);
        NCCT_img_3 = imresize(NCCT_img_3,[256 256]);
        
        mask_fin = (NCCT_img_2 ~= 0);
        NCCT_img_1(~mask_fin)=0;
        NCCT_img_2(~mask_fin)=0;
        NCCT_img_3(~mask_fin)=0;
        
        NCCT_img = cat(3, NCCT_img_1, NCCT_img_2, NCCT_img_3);

        saveName = strcat(subject_name(1:8),'_',num2str(slice_num),'.bmp');
       
%         mask_fin_1 = (NCCT_img_1~=0);
%         mask_fin_2 = (NCCT_img_2~=0);
%         mask_fin_3 = (NCCT_img_3~=0);
        %mask_fin = or(mask_fin_1,or(mask_fin_2,mask_fin_3));
        
        MTT_img_fin = applyNCCTMask(MTT_img,mask_fin);
        rCBF_img_fin = applyNCCTMask(rCBF_img,mask_fin);
        rCBV_img_fin = applyNCCTMask(rCBV_img,mask_fin);
        TTP_img_fin = applyNCCTMask(TTP_img,mask_fin);
        
        if all(NCCT_img_1(:)==0) || all(NCCT_img_2(:)==0) || all(NCCT_img_3(:)==0)
            continue;
        elseif all(MTT_img_fin(:)==0) || all(rCBF_img_fin(:)==0) || all(rCBV_img_fin(:)==0) || all(TTP_img_fin(:)==0)
            continue;
        end
        
%         figure; movegui('north');
%         subplot(331);imshow(NCCT_img_store_1);title('NCCT_1');subplot(331);imshow(NCCT_img_store_2);title('NCCT_2');
%         subplot(333);imshow(NCCT_img_store_1);title('NCCT_3');
%         subplot(334);imshow(MTT_img);title('MTT');subplot(336);imshow(rCBF_img);title('rCBF');
%         subplot(337);imshow(rCBV_img);title('rCBV');subplot(339);imshow(TTP_img);title('TTP');
%         
%         f=figure; movegui('south');
%         text_height = size(NCCT_img,1)+15;
%         subplot(431);imshow(NCCT_img_store_1);title('NCCT_1 Before Crop');text(1,size(NCCT_img_store_1,1)+30,strcat('z-coordinate: ',num2str(NCCT_z_1)),'FontSize',8);
%         subplot(432);imshow(NCCT_img_store_2);title('NCCT_2 Before Crop');text(1,size(NCCT_img_store_2,1)+30,strcat('z-coordinate: ',num2str(NCCT_z_2)),'FontSize',8);
%         subplot(433);imshow(NCCT_img_store_3);title('NCCT_3 Before Crop');text(1,size(NCCT_img_store_3,1)+30,strcat('z-coordinate: ',num2str(NCCT_z_3)),'FontSize',8);
% 
%         subplot(434);imshow(NCCT_img_1);title('NCCT_1 After Crop');text(1,text_height,strcat('z-coordinate: ',num2str(NCCT_z_1)),'FontSize',8);
%         subplot(435);imshow(NCCT_img_2);title('NCCT_2 After Crop');text(1,text_height,strcat('z-coordinate: ',num2str(NCCT_z_2)),'FontSize',8);
%         subplot(436);imshow(NCCT_img_3);title('NCCT_3 After Crop');text(1,text_height,strcat('z-coordinate: ',num2str(NCCT_z_3)),'FontSize',8);
% 
%         subplot(437);imshow(MTT_img_fin);title('MTT');text(1,text_height,strcat('z-coordinate: ',num2str(MTT_z)),'FontSize',8);
%         subplot(439);imshow(rCBF_img_fin);title('rCBF');text(1,text_height,strcat('z-coordinate: ',num2str(rCBF_z)),'FontSize',8);
%         subplot(4,3,10);imshow(rCBV_img_fin);title('rCBV');text(1,text_height,strcat('z-coordinate: ',num2str(rCBV_z)),'FontSize',8);
%         subplot(4,3,12);imshow(TTP_img_fin);title('TTP');text(1,text_height,strcat('z-coordinate: ',num2str(TTP_z)),'FontSize',8);
%         save_check = input('Keep this file? (y/n): ','s');
        save_check = 'y';
        %close all;
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
            %saveas(f,fullfile('C:/Users/gfullerton/Desktop/pics_new/',strcat(saveName,'.png')));
            %close all;
            slice_num=slice_num+1;
        end
    end
    fprintf('----------Finished with subject %s----------\n',subject_name);
end
disp('----------Finished with all----------');
