function [] = splitData(input_path,test_size)
%% Description
% The current use of the code is to take the results from
% findSliceMatch_RAPID.m and split the subjects into hold out splits.
% Expects input to have NCCT, rCBF, rCBV, MTT, and TTP folders. Each folder
% has similarly named files. All files for a given subject are stratified.
% Reorganizes all files following the same structure.
% 
% For now, the dataset is split as best as it can to follow the given
% test_size. The validation set will become the same size as the test_size.
% 
% Input
% |-- dataset
%   |-- NCCT
%     |-- 100000_1.bmp
%     |-- 100000_2.bmp
%     |-- 209271_1.bmp
%     |-- 451281_1.bmp    
%   |-- rCBF
%     |-- 100000_1.bmp
%     |-- 100000_2.bmp
%     |-- 209271_1.bmp
%     |-- 451281_1.bmp
%   |-- ...
% 
% Output
% |-- dataset
%   |-- NCCT
%     |-- train
%       |-- 100001_1.bmp 
%       |-- 100001_2.bmp
%       |-- 100001_3.bmp
%       |-- ...
%     |-- val
%       |-- 100002_1.bmp
%       |-- 100002_2.bmp
%       |-- ...
%     |-- test
%       |-- ...
%   |-- rCBV
%   |-- ...
% 
%   Kyle See 06/01/2023
%   Smart Medical Informatics Learning and Evaluation (SMILE)
%   Biomedical Engineering
% 
%   Input:
%       input_path - Path to data.
%       test_size  - Size of hold out and validation set [0,1].

%% Adjustable Variables
% #########################################
% close all; clear; clc;
% input_path = fullfile('D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\output');
% test_size = 0.2; % Ideally between [0.1 and 0.2]
% #########################################

fprintf("Starting...splitData.m\n")
fprintf("------------------------------------------------------------------\n")

% Set RNG to default
rng('default')

%% Setup
% Setup expected subfolders for NCCT and perfusion modalities
path_ncct = fullfile(input_path,'NCCT');
path_mtt = fullfile(input_path,'MTT');
path_ttp = fullfile(input_path,'TTP');
path_rcbf = fullfile(input_path,'rCBF');
path_rcbv = fullfile(input_path,'rCBV');


% Check if completed already
if ~exist(fullfile(path_ncct,'train'),'dir') && ~exist(fullfile(path_ncct,'val'),'dir') && ~exist(fullfile(path_ncct,'test'),'dir')
    % Get directory of all bmp images
    data_dir = dir(fullfile(path_ncct,'*.png'));
    data_names = {data_dir.name}'; % Convert to string
    
    %% Train/Val/Test Splits
    % Find unique subject IDs and convert them to string
    subj_names = extractBefore(data_names,'_'); % Extract subject IDs
    unique_names = unique(subj_names); % Find all unique subject IDs
    data_names_string = string(data_names); % Convert to string for later use
    
    % Create a grouping for subject-level stratification based on amt of data
    % - unique_names and subj_amt should have the same size
    subj_amt = size(unique_names)';
    for i = 1:length(unique_names)
        subj_amt(i) = sum(contains(data_names_string,unique_names{i}));
    end
    
    % Use cvpartition to create a train and test set. We will use the train set
    % to create a validation set that is the same size as the test set.
    cv = cvpartition(subj_amt,'HoldOut',test_size);
    
    % Use cvpartition again to create a train and validation set.
    val_size = sum(cv.test)/sum(cv.training);          % Calc size of val size based on resulting test size
    grouping_train = subj_amt(cv.training);            % Create another grouping but with only train set
    unique_train = unique_names(cv.training);
    cv_val = cvpartition(grouping_train,'HoldOut',val_size);
    
    % Get actual ratio of images used in each set.
    % *ratios vary since each subj has different # of images
    ratio_train = sum(cv_val.training.*grouping_train)/sum(subj_amt);
    ratio_val = sum(cv_val.test.*grouping_train)/sum(subj_amt);
    ratio_test = sum(cv.test.*subj_amt)/sum(subj_amt);
    
    % Separate all of the subj IDs into each partition
    unique_names_train = string(unique_train(cv_val.training));
    unique_names_val = string(unique_train(cv_val.test));
    unique_names_test = string(unique_names(cv.test));
    
    fprintf("Intended split: Train-%.2f Val-%.2f Test-%.2f\n",1-test_size-val_size,val_size,test_size)
    fprintf("Initial split:  Train-%.2f Val-%.2f Test-%.2f\n",ratio_train,ratio_val,ratio_test)
    fprintf("------------------------------------------------------------------\n")
    
    path_ncct = fullfile(input_path,'NCCT');
    path_mtt = fullfile(input_path,'MTT');
    path_ttp = fullfile(input_path,'TTP');
    path_rcbf = fullfile(input_path,'rCBF');
    path_rcbv = fullfile(input_path,'rCBV');
    
    %% Moving the data
    % Create train/val/test paths
    train_path_ncct = fullfile(path_ncct,'train');
    val_path_ncct = fullfile(path_ncct,'val');
    test_path_ncct = fullfile(path_ncct,'test');
    
    % Make directories if they don't exist yet
    if ~exist(train_path_ncct,'dir'), mkdir(train_path_ncct), end
    if ~exist(val_path_ncct,'dir'), mkdir(val_path_ncct), end
    if ~exist(test_path_ncct,'dir'), mkdir(test_path_ncct), end
    
    moveFiles(unique_names_train,data_names_string,path_ncct,train_path_ncct)
    moveFiles(unique_names_val,data_names_string,path_ncct,val_path_ncct)
    moveFiles(unique_names_test,data_names_string,path_ncct,test_path_ncct)
    
    %========================================================================
    
    % Create train/val/test paths
    train_path_mtt = fullfile(path_mtt,'train');
    val_path_mtt = fullfile(path_mtt,'val');
    test_path_mtt = fullfile(path_mtt,'test');
    
    % Make directories if they don't exist yet
    if ~exist(train_path_mtt,'dir'), mkdir(train_path_mtt), end
    if ~exist(val_path_mtt,'dir'), mkdir(val_path_mtt), end
    if ~exist(test_path_mtt,'dir'), mkdir(test_path_mtt), end
    
    moveFiles(unique_names_train,data_names_string,path_mtt,train_path_mtt)
    moveFiles(unique_names_val,data_names_string,path_mtt,val_path_mtt)
    moveFiles(unique_names_test,data_names_string,path_mtt,test_path_mtt)
    
    %========================================================================
    
    % Create train/val/test paths
    train_path_ttp = fullfile(path_ttp,'train');
    val_path_ttp = fullfile(path_ttp,'val');
    test_path_ttp = fullfile(path_ttp,'test');
    
    % Make directories if they don't exist yet
    if ~exist(train_path_ttp,'dir'), mkdir(train_path_ttp), end
    if ~exist(val_path_ttp,'dir'), mkdir(val_path_ttp), end
    if ~exist(test_path_ttp,'dir'), mkdir(test_path_ttp), end
    
    moveFiles(unique_names_train,data_names_string,path_ttp,train_path_ttp)
    moveFiles(unique_names_val,data_names_string,path_ttp,val_path_ttp)
    moveFiles(unique_names_test,data_names_string,path_ttp,test_path_ttp)
    
    %========================================================================
    
    % Create train/val/test paths
    train_path_rcbf = fullfile(path_rcbf,'train');
    val_path_rcbf = fullfile(path_rcbf,'val');
    test_path_rcbf = fullfile(path_rcbf,'test');
    
    % Make directories if they don't exist yet
    if ~exist(train_path_rcbf,'dir'), mkdir(train_path_rcbf), end
    if ~exist(val_path_rcbf,'dir'), mkdir(val_path_rcbf), end
    if ~exist(test_path_rcbf,'dir'), mkdir(test_path_rcbf), end
    
    moveFiles(unique_names_train,data_names_string,path_rcbf,train_path_rcbf)
    moveFiles(unique_names_val,data_names_string,path_rcbf,val_path_rcbf)
    moveFiles(unique_names_test,data_names_string,path_rcbf,test_path_rcbf)
    
    %========================================================================
    
    % Create train/val/test paths
    train_path_rcbv = fullfile(path_rcbv,'train');
    val_path_rcbv = fullfile(path_rcbv,'val');
    test_path_rcbv = fullfile(path_rcbv,'test');
    
    % Make directories if they don't exist yet
    if ~exist(train_path_rcbv,'dir'), mkdir(train_path_rcbv), end
    if ~exist(val_path_rcbv,'dir'), mkdir(val_path_rcbv), end
    if ~exist(test_path_rcbv,'dir'), mkdir(test_path_rcbv), end
    
    moveFiles(unique_names_train,data_names_string,path_rcbv,train_path_rcbv)
    moveFiles(unique_names_val,data_names_string,path_rcbv,val_path_rcbv)
    moveFiles(unique_names_test,data_names_string,path_rcbv,test_path_rcbv)
    
    fprintf("Finished...splitData.m\n")
    fprintf("------------------------------------------------------------------\n")

else
    fprintf("Dataset already partitioned.\n")
    fprintf("Finished...splitData.m\n")
    fprintf("------------------------------------------------------------------\n")

end
end
%% Local Functions
function moveFiles(unique_names,dataset,input_path,output_path)
    for iter = 1:length(unique_names)
        img_logical = contains(dataset, unique_names(iter));
        idx = find(img_logical == 1);
        for iter_img = 1:length(idx)
            imgFilename = dataset(idx(iter_img));
            inputFilename = fullfile(input_path,imgFilename);
            outputFilename = fullfile(output_path,imgFilename);
%             disp(inputFilename)
%             disp(outputFilename)
%             disp('---------------------------------------')
            if exist(inputFilename,'file')
                movefile(inputFilename,outputFilename)
            end
        end
    end
end