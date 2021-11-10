clc; clear; close all;

folders = {'test_results_710_lr1'};

for k = 1:length(folders)
    folder_name = cell2mat(folders(k));
    
    
input_folder = fullfile(strcat('C:/Users/Garrett/Desktop/new_augmented_data/', folder_name, '_fakereal_combined_v2/'));
fake_folder = fullfile(input_folder,'fake');
ncct_folder = fullfile(input_folder,'ncct');
real_folder = fullfile(input_folder,'real');
output_folder = fullfile(input_folder,'combined');
if ~exist(output_folder,'dir'),mkdir(output_folder);end
ncct_files = dir(ncct_folder);
parfor i = 1:length(ncct_files)
    if strcmp(ncct_files(i).name(1),'.'),continue;end
    ncct_img = imread(fullfile(ncct_folder,ncct_files(i).name));
    try
        fake_name = strrep(ncct_files(i).name,'.png','_Simulated.png');
        real_name = strrep(ncct_files(i).name,'.png','_Real.png');
    
        fake_img = imread(fullfile(fake_folder,fake_name));
        real_img = imread(fullfile(real_folder,real_name));
    catch
        continue;
    end
    white_img = uint8(ones(size(fake_img)))*255;
    center1 = floor(size(white_img,1)/2);
    center2 = floor(size(white_img,2)/2);
    white_img(center1-127:center1+128,center2-127:center2+128,1) = ncct_img;
    white_img(center1-127:center1+128,center2-127:center2+128,2) = ncct_img;
    white_img(center1-127:center1+128,center2-127:center2+128,3) = ncct_img;
    img_final = cat(2,white_img,fake_img,real_img);
    
    imwrite(img_final,fullfile(output_folder,ncct_files(i).name));
    fprintf('done with %s\n',ncct_files(i).name);
end
end
disp('all done');
load handel; sound(y, Fs);
