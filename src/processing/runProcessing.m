function [] = runProcessing(deid_path,partition_path,dataset_path,test_ratio)
%% Run Processing
% This code handles all processing steps. Calls different functions to
% process specifically UF Health deidentified CT data. Deidentification
% scripts are from https://github.com/lab-smile/DICOM-Deidentification.
% Listed below are the main functions used.
%
% findSliceMatch_RAPID.m - Finds matches between z-coords of NCCT and CTP
%   perfusion maps. Uses NCCT as base. By default, uses a 2mm threshold for
%   CTP matching and 4mm offset for NCCT stacking to create pseudo RGB
%   image. Saves results based on modality (NCCT, TTP, MTT, CBV, CBF).
%
% splitData.m - Uses cvpartition to split subjects data into training,
%   validation, and testing splits. Splits are subject-stratified. Same
%   splits are stratified across modalities.
%
%   *cvpartition does not work well with smaller datasets.
%
% newp2pdataset.m - Concatenates NCCT and CTP perfusion maps into a single
%   1x5 montage. This image will be used for training and testing for
%   MAGIC. The input path expects separate modality folders, each with a
%   training, validation, and testing folder.
%
%   Kyle See 08/21/2023
%   Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%   Biomedical Engineering
%
%----------------------------------------
% Last Updated: 8/22/2023 by KS

%% Adjustable Variables
%#########################################
% clc; clear; close all; warning off;
% deid_path = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\deid';
% partition_path = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\partition';
% dataset_path = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\dataset_real';
% test_ratio = 0.2;
%#########################################
matchNcctAndRapid(deid_path,partition_path)
partitionData(partition_path,test_ratio)
concatenateMaps(partition_path,dataset_path)
end