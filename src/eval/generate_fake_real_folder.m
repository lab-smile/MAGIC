%% Organize test results into fake and real folders
% The current use of this code is to apply colormaps to each perfusion
% image and to save the outputs into a structure. This structure first
% separates images into fake (test results) and real (input) folders. Each
% folder is further separated into modalities. Fake contains MTT, TTP, CBF,
% and CBV. Real contains MTT, TTP, CBF, CBV, and NCCT.
% 
%   Garrett Fullerton 10/18/2020
%   Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%   Biomedical Engineering
% 
%----------------------------------------
% Last Updated: 8/17/2023 by KS
% 
% 08/17/2023 by KS
% - Added comments and description
%
%% Adjustable Variables
% #########################################
close all; clear; clc;
% folders = {'test_results'};
addpath('../processing/');

%parpool;

% for k = 1:length(folders)
method = 'median'; %postprocessing method - median was used to achieve final results
% folder_name = cell2mat(folders(k));

% fake_image_folder = fullfile(strcat('C:\Users\Garrett\Desktop\MAGIC\DEMO_RESULTS\', folder_name));
% real_image_folder = fullfile('C:\Users\Garrett\Desktop\MAGIC\src\sample\test');
% savepath = fullfile(strcat('C:\Users\Garrett\Desktop\MAGIC\DEMO_RESULTS\', folder_name, '_fakereal/'));

fake_image_folder = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\fake\';
real_image_folder = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\real\';
savepath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\fakereal\';

disp(fake_image_folder);
disp(real_image_folder);
disp(savepath);

if ~exist(savepath,'dir'),mkdir(savepath);end

load('Rapid_Colormap.mat');
c_map = Rapid_U;
unit = 256; %img px size
realsavepath = makeSubfolder(savepath,'real_images');
fakesavepath = makeSubfolder(savepath,'fake_images');
%make ncct images subfolders

fake_img_folder = fullfile(fake_image_folder); %png
real_img_folder = fullfile(real_image_folder); %bmp

images = dir(fake_img_folder);

for i = 1:length(images)
    img = images(i);
    imgname_fake = img.name;
    if strcmp(imgname_fake(1),'.'), continue; end
    imgname_real = strrep(imgname_fake,'_output','');
    imgname_real = strrep(imgname_real,'.png','.bmp');
    
    fake_img = imread(fullfile(img.folder,imgname_fake));
    real_img = imread(fullfile(real_img_folder,imgname_real));
    
    mtt_f = rgb2gray(fake_img(:,unit*0+1:unit*1,:));
    ttp_f = rgb2gray(fake_img(:,unit*1+1:unit*2,:));
    rcbf_f = rgb2gray(fake_img(:,unit*2+1:unit*3,:));
    rcbv_f = rgb2gray(fake_img(:,unit*3+1:unit*4,:));
    
    mtt_f = applyImageDenoising(mtt_f,method);
    ttp_f = applyImageDenoising(ttp_f,method);
    rcbf_f = applyImageDenoising(rcbf_f,method);
    rcbv_f = applyImageDenoising(rcbv_f,method);
    
    
    ncct_r = real_img(:,unit*0+1:unit*1,2);
    mtt_r = rgb2gray(real_img(:,unit*1+1:unit*2,:));
    ttp_r = rgb2gray(real_img(:,unit*2+1:unit*3,:));
    rcbf_r = rgb2gray(real_img(:,unit*3+1:unit*4,:));
    rcbv_r = rgb2gray(real_img(:,unit*4+1:unit*5,:));
    %     %color
    saveImageFinal(mtt_f, c_map, imgname_real, fakesavepath, 'MTT');
    saveImageFinal(ttp_f, c_map, imgname_real, fakesavepath, 'TTP');
    saveImageFinal(rcbf_f, c_map, imgname_real, fakesavepath, 'CBF');
    saveImageFinal(rcbv_f, c_map, imgname_real, fakesavepath, 'CBV');
    %color
    saveImageFinal(mtt_r, c_map, imgname_real, realsavepath, 'MTT');
    saveImageFinal(ttp_r, c_map, imgname_real, realsavepath, 'TTP');
    saveImageFinal(rcbf_r, c_map, imgname_real, realsavepath, 'CBF');
    saveImageFinal(rcbv_r, c_map, imgname_real, realsavepath, 'CBV');
    
    %gray
    %     imwrite(mtt_r,fullfile(makeSubfolder(realsavepath,'MTT'),imgname_real));
    %     imwrite(ttp_r,fullfile(makeSubfolder(realsavepath,'TTP'),imgname_real));
    %     imwrite(rcbf_r,fullfile(makeSubfolder(realsavepath,'CBF'),imgname_real));
    %     imwrite(rcbv_r,fullfile(makeSubfolder(realsavepath,'CBV'),imgname_real));
    imwrite(ncct_r,fullfile(makeSubfolder(realsavepath,'NCCT'),imgname_real));
    
    fprintf('Done with %s\n',imgname_real);
end
% end
disp('Completed');


function newfilepath = makeSubfolder(savepath,folder_name)
newfilepath = fullfile(savepath,folder_name);
if ~exist(newfilepath,'dir')
    mkdir(newfilepath);
end
end

function saveImageFinal(mtt_f, c_map, imgname_real, savepath, modality)
figure('visible','off'); imshow(mtt_f); colormap(c_map);
f = getframe;
mtt_f_savepath = makeSubfolder(savepath,modality);
savename = fullfile(mtt_f_savepath,imgname_real);
imwrite(f.cdata,savename);
close all;
end
