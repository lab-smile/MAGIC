%% Driver for separating patients after collage making
% It is crucial to do this after collage making as the number of images per
% patient within each different modalitity is no longer 10, it is now 11
% because of the collage.
%
%Separate Patients will take the following file structure:
%   folder_with_images
%       fake
%           CBF
%               ID_slice.bmp
%               ID_slice.bmp
%               ID_slice.bmp
%           CBV
%           MTT
%           TTP
%       real
%           NCCT
%           CBF
%           CBV
%           MTT
%           TTP
%It will produce this file structure:
%   patients:
%       ID_1
%           NCCT
%           fake_images
%               CBF
%               CBV
%               MTT
%               TTP
%           real_images
%               CBF
%               CBV
%               MTT
%               TTP
%       ID_2
%           .
%           .
%           .
%% Change Paths where appropriate

p_deident = genpath('C:/Users/Simon Kato/Desktop/Research/REU/scripts/utilities/');
addpath(p_deident);

all_image_path = 'C:\Users\skato1\Desktop\REU\data\patients_filter_collage';
output_path = 'C:\Users\skato1\Desktop\REU\data\patients_filter';

%% Do not edit below this point
all_images = fixDir(all_image_path);
patients = importdata('patient_test.xlsx');

for i = 1 : length(all_images)
   image_type_path = strcat(all_images(i).folder, '\', all_images(i).name);
   image_type_folder = fixDir(image_type_path);
   image_type = all_images(i).name;
   
   for j = 1 : length(image_type_folder)
      modality = image_type_folder(j);
      modality_name = modality.name;
      
      modality_images = fixDir(strcat(modality.folder,'\',modality.name));
      numPatients = 62;
      
      for k = 1 : numPatients
          patientID = patients{k};
          if not(isfolder(fullfile(output_path,patientID)))
              mkdir(fullfile(output_path,patientID));
              mkdir(fullfile(output_path,patientID, 'fake_images'));
              mkdir(fullfile(output_path,patientID, 'real_images'));
              mkdir(fullfile(output_path, patientID, 'NCCT'));
              mkdir(fullfile(output_path, patientID, 'fake_images', 'CBF'));
              mkdir(fullfile(output_path, patientID, 'fake_images', 'CBV'));
              mkdir(fullfile(output_path, patientID, 'fake_images', 'MTT'));
              mkdir(fullfile(output_path, patientID, 'fake_images', 'TTP'));
              mkdir(fullfile(output_path, patientID, 'real_images', 'CBF'));
              mkdir(fullfile(output_path, patientID, 'real_images', 'CBV'));
              mkdir(fullfile(output_path, patientID, 'real_images', 'MTT'));
              mkdir(fullfile(output_path, patientID, 'real_images', 'TTP'));
          end
          
          if strcmp(modality.name,'NCCT')
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_1.bmp')), fullfile(output_path, patientID, modality_name, strcat(patientID,'_1.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_2.bmp')), fullfile(output_path, patientID, modality_name, strcat(patientID,'_2.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_3.bmp')), fullfile(output_path, patientID, modality_name, strcat(patientID,'_3.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_4.bmp')), fullfile(output_path, patientID, modality_name, strcat(patientID,'_4.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_5.bmp')), fullfile(output_path, patientID, modality_name, strcat(patientID,'_5.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_6.bmp')), fullfile(output_path, patientID, modality_name, strcat(patientID,'_6.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_7.bmp')), fullfile(output_path, patientID, modality_name, strcat(patientID,'_7.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_8.bmp')), fullfile(output_path, patientID, modality_name, strcat(patientID,'_8.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_9.bmp')), fullfile(output_path, patientID, modality_name, strcat(patientID,'_9.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_10.bmp')), fullfile(output_path, patientID, modality_name, strcat(patientID,'_10.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_collage.bmp')), fullfile(output_path, patientID, modality_name, strcat(patientID,'_collage.bmp'))); catch end
          else
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_1.bmp')), fullfile(output_path, patientID, image_type, modality_name, strcat(patientID,'_1.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_2.bmp')), fullfile(output_path, patientID, image_type, modality_name, strcat(patientID,'_2.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_3.bmp')), fullfile(output_path, patientID, image_type, modality_name, strcat(patientID,'_3.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_4.bmp')), fullfile(output_path, patientID, image_type, modality_name, strcat(patientID,'_4.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_5.bmp')), fullfile(output_path, patientID, image_type, modality_name, strcat(patientID,'_5.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_6.bmp')), fullfile(output_path, patientID, image_type, modality_name, strcat(patientID,'_6.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_7.bmp')), fullfile(output_path, patientID, image_type, modality_name, strcat(patientID,'_7.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_8.bmp')), fullfile(output_path, patientID, image_type, modality_name, strcat(patientID,'_8.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_9.bmp')), fullfile(output_path, patientID, image_type, modality_name, strcat(patientID,'_9.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_10.bmp')), fullfile(output_path, patientID, image_type, modality_name, strcat(patientID,'_10.bmp'))); catch end
              try copyfile(fullfile(modality.folder, modality.name, strcat(patientID,'_collage.bmp')), fullfile(output_path, patientID, image_type, modality_name, strcat(patientID,'_collage.bmp'))); catch end
          end
      end
   end
end