%% Inspect your Dataset

%% Adjustable Variables
% #########################################
close all; clear; clc;
inputPath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\dataset\train';
% #########################################
% Add utilities
addpath('../toolbox/utilities')

fprintf("Starting...inspectDataset.m\n")
fprintf("------------------------------------------------------------------\n")

% Construct file paths for train, test, and output paths
[file_path,folder_name,~] = fileparts(inputPath);
output_path = fullfile(file_path,['inspect_',folder_name]);
slice_path = fullfile(output_path,'slice');

% Create output directory if needed
if ~exist(output_path,'dir'),mkdir(output_path);end
if ~exist(slice_path,'dir'),mkdir(slice_path);end

% Prepare colormap
load('Rapid_Colormap.mat');
c_map = Rapid_U;
unit = 256; %img size

% Merge all filepaths into one big struct
images = dir(inputPath);

for i = 1:length(images)
    % Construct image filenames
    img_struct = images(i);
    img_name = img_struct.name;
    if strcmp(img_name(1),'.'), continue; end % Skip . and ..
    
    img = imread(fullfile(img_struct.folder,img_name));
    
    ncct = img(:,unit*0+1:unit*1,2);
    mtt = rgb2gray(img(:,unit*1+1:unit*2,:));
    ttp = rgb2gray(img(:,unit*2+1:unit*3,:));
    cbf = rgb2gray(img(:,unit*3+1:unit*4,:));
    cbv = rgb2gray(img(:,unit*4+1:unit*5,:));
    
    mtt = applyColormap(mtt,c_map);
    ttp = applyColormap(ttp,c_map);
    cbf = applyColormap(cbf,c_map);
    cbv = applyColormap(cbv,c_map);
    
    ncct(:,:,2) = ncct(:,:,1);
    ncct(:,:,3) = ncct(:,:,1);
    
    slice = cat(2,ncct,mtt,ttp,cbf,cbv);
    savename = fullfile(slice_path,img_name);
    fprintf("Saving %s\n",img_name)
    imwrite(slice,savename)
end

fprintf("------------------------------------------------------------------\n")
fprintf("Finished...inspectDataset.m\n")
fprintf("------------------------------------------------------------------\n")

%% Local Functions
function img_cmap = applyColormap(img,cmap)
hFig = figure('visible','off');
imshow(img);
colormap(cmap);
f = getframe;
img_cmap = f.cdata;
close(hFig);
end