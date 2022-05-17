function [averageDice, medianDice] = generate_dice(datasetPath, threshold, save_path, save_figs)
%% Function Header
% Description:
%   Finds the average dice and median dice values for nifti image files
%   which contain probability maps. In specific, this code is written to
%   handle the output of Albert's ISLES2018 model. The input, identified in
%   the datasetPath variable, is exactly the output of the model.
%
% Comments:
%   It is assumed that ground truth and synthesized nifti probability maps
%   alternate between even and odd. That is, each consequtive pair of
%   images contain the synthesized and the ground truth probability maps.
%
% Inputs:
%   datasetPath : path to dataset with patients, importantly, structure of
%       the patients within the dataset must be the output of the ISLES2018
%       model with consequtive pairs containing one ground truth and one
%       synthesized. 
%
%   Threshold: The threshold value for which to construct the binary masks.
%       That is, values larger than the threshold in the probability maps
%       will become 1 in the binary image and those strictly less than will
%       be 0. Threshold value used by us is 0.45
%
%   save_path: If you wish to save figures, the desination folder
%
%
%   save_figs: 0 or 1 to identify whether to save figures or not. 0 does
%   not and 1 does.
%
% Output:
%   The median and average dice value for the dataset.
%
% Written by : Simon Kato
%              Smile-LAB @UF
%% Add utilitie functions to the path
current_directory = pwd();
cd("../utilities")
utilities = pwd();
cd(current_directory)

p_deident = genpath(utilities);
addpath(p_deident);
%% Main Function

datasetPath = createPath(datasetPath);
save_path = createPath(save_path);
patientList = importdata('patients.xlsx');

niftiData = dir(datasetPath);
niftiData = fixDir(niftiData);

allDice = cell(1, length(niftiData)/2);

for i = 1:length(niftiData)/2
    synNifti = niftiread(strcat(datasetPath, num2str(2*i - 1), '_test_probs.nii'));
    gtNifti = niftiread(strcat(datasetPath, num2str(2*i), '_test_probs.nii'));
    
    tempDice = calculate_dice(synNifti, gtNifti, threshold, strcat(save_path, patientList{i}), save_figs);
    allDice{i} = tempDice;
end
%% Analysis

numComponents = 0;
sumDice = 0;
nonZeroDice = [];

for i = 1:length(allDice)
    tempDice = allDice{i};
    
    nanArray = 1 - isnan(tempDice);
    
    nonZeroDice = [nonZeroDice, tempDice(nanArray == 1)];
    
end

averageDice = mean(nonZeroDice);
averageDice
medianDice = median(nonZeroDice);
medianDice
end