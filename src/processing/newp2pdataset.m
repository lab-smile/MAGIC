function [] = newp2pdataset(input_path,output_path)
%% Description
% The current use of the code is to concatenate the NCCT and CTP maps into
% a single 1x5 image. This image will be used for training and testing in
% MAGIC. The input path expects an NCCT, MTT, TTP, rCBF, and rCBV folder,
% each with a train, test, and val folder.
% 
% Input
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

%% Adjustable Variables
% #########################################
% close all; clear; clc;
% input_path = fullfile('D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\output');
% output_path = fullfile('D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\newput');
% #########################################

fprintf("Starting...newp2pdataset.m\n")
fprintf("------------------------------------------------------------------\n")

ncct_path = fullfile(input_path,'NCCT');
mtt_path = fullfile(input_path,'MTT');
ttp_path = fullfile(input_path,'TTP');
rcbf_path = fullfile(input_path,'rCBF');
rcbv_path = fullfile(input_path,'rCBV');

if ~exist(output_path, 'dir'), mkdir(output_path); end

for i = 1:3
    switch i
        case 1
            split = 'train';
        case 2
            split = 'test';
        case 3
            split = 'val';
    end
    savepath = fullfile(output_path, split);
    if ~exist(savepath, 'dir'), mkdir(savepath); end
    
    ncct_files = dir(fullfile(ncct_path, split, '*.bmp'));
    
    for j = 1:length(ncct_files)
        ncct_file = ncct_files(j);
        filename = ncct_file.name;
        ncct_filepath = fullfile(ncct_file.folder, ncct_file.name);
        mtt_filepath = fullfile(mtt_path, split, filename);
        ttp_filepath = fullfile(ttp_path, split, filename);
        rcbf_filepath = fullfile(rcbf_path, split, filename);
        rcbv_filepath = fullfile(rcbv_path, split, filename);
        
        ncct_img = imread(ncct_filepath);
        mtt_img = imread(mtt_filepath);
        ttp_img = imread(ttp_filepath);
        rcbf_img = imread(rcbf_filepath);
        rcbv_img = imread(rcbv_filepath);
        
        ncct_img = fix_img(ncct_img);
        mtt_img = fix_img(norm_img(mtt_img));
        ttp_img = fix_img(norm_img(ttp_img));
        rcbf_img = fix_img(norm_img(rcbf_img));
        rcbv_img = fix_img(norm_img(rcbv_img));
        
        newimg = cat(2, ncct_img, mtt_img, ttp_img, rcbf_img, rcbv_img);
        
        
        savename = fullfile(savepath, filename);
        imwrite(newimg, savename);
        
        fprintf('Done saving %s\n', filename);
    end
end

fprintf("------------------------------------------------------------------\n")
fprintf("Finished...newp2pdataset.m\n")
fprintf("------------------------------------------------------------------\n")

end

%% Local Functions
function fixed_img = fix_img(orig_img)
fixed_img = orig_img;
if ndims(fixed_img) == 2
    new_img = uint8(zeros(size(fixed_img, 1), size(fixed_img, 2), 3));
    new_img(:, :, 1) = fixed_img;
    new_img(:, :, 2) = fixed_img;
    new_img(:, :, 3) = fixed_img;
    fixed_img = new_img;
end
end

function normed_img = norm_img(orig_img)
if ~strcmp(class(orig_img),'double')
    orig_img = im2double(orig_img);
end

pmin = min(orig_img(:));
pmax = max(orig_img(:));
pdiff = pmax-pmin;

normed_img = (orig_img-pmin)/pdiff * 255;

if ~strcmp(class(normed_img),'uint8')
    normed_img = uint8(normed_img);
end
end