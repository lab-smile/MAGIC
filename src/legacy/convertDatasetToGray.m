clc; clear; close all;

inputpath = 'C:/Users/Garrett/Desktop/rapid_data_raw/rapid_data_raw/';
outputpath = 'C:/Users/Garrett/Desktop/rapid_data_gray/';

addpath(genpath('C:/Users/Garrett/Desktop/REU/scripts/'));
addpath('C:/Users/Garrett/Desktop/');
load('Rapid_U.mat');
load('Rainbow_CBP_4.mat');

if ~exist(outputpath,'dir'), mkdir(outputpath); end
mods = dir(inputpath);

for modidx = 1:length(mods)
    copy=false;
    mod = mods(modidx);
    if strcmp(mod.name(1),'.'), continue; end
    if strcmp(mod.name,'NCCT'), copy=true; end
    
    if ~exist(fullfile(outputpath,mod.name),'dir'), mkdir(fullfile(outputpath,mod.name)); end
    splits = dir(fullfile(mod.folder,mod.name));
    for i = 1:length(splits)
        split = splits(i);
        if strcmp(split.name(1),'.'),continue;end
        splitpath = fullfile(outputpath,mod.name,split.name);
        if ~exist(splitpath,'dir'),mkdir(splitpath);end
        files = dir(fullfile(inputpath,mod.name,split.name));
        
        parfor j = 1:length(files)
            file = files(j);
            if strcmp(file.name(1),'.'),continue;end
            savePath = fullfile(splitpath,file.name);
            inputfilepath = fullfile(inputpath,mod.name,split.name,file.name);
            
            if copy
                copyfile(inputfilepath,savePath);
                continue;
            end
            
            img = imread(fullfile(file.folder,file.name));
            
            if strcmp(mod.name,'Delay')
                modname = 'DLY';
            elseif strcmp(mod.name,'rCBF')
                modname = 'CBF';
            elseif strcmp(mod.name,'rCBV')
                modname = 'CBV';
            else
                modname = mod.name;
            end
            
            img_vals = rgb2values(img,Rapid_U,'gray');
            parsave(savePath,uint8(img_vals));
            fprintf('Done saving %s\n',savePath);
        end
    end
    fprintf('-----Done saving %s files-----\n',mod.name);
end
disp('-----Done with everything!-----');
