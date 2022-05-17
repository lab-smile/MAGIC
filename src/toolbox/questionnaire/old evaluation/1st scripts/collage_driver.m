%% Script that will run make_collage on all modalities given the path to folder with images
% Assumes the following file structure:
%   folder_with_images
%       fake
%           CBF
%           CBV
%           MTT
%           TTP
%       real
%           NCCT
%           CBF
%           CBV
%           MTT
%           TTP

%% Change paths to appropriate paths
current_directory = pwd();
cd("../utilities")
utilities = pwd();
cd(current_directory)

p_deident = genpath(utilities);
addpath(p_deident);

all_image_path = 'C:\Users\skato1\Desktop\REU\data\patients_filter';

%% Do not edit 
all_images = fixDir(all_image_path);

for i = 1 : length(all_images)
   cur_image_folder_path = strcat(all_images(i).folder, '\', all_images(i).name);
   cur_image_folder = fixDir(cur_image_folder_path);
   
   for j = 1 : length(cur_image_folder)
      modality = cur_image_folder(j);
      make_collage(strcat(modality.folder, '\', modality.name), strcat(modality.folder, '\', modality.name));
   end
end