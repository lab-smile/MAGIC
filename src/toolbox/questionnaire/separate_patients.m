%% Driver for separating patients and creating column views given a patient list
%
%Separate Patients will take the following file structure:
%folder_with_images
%       fake
%           CBF
%               ID_slice.bmp
%               ID_slice.bmp
%               ID_slice.bmp
%           CBV
%           MTT
%           TMAX
%       real
%           NCCT
%           CBF
%           CBV
%           MTT
%           TMAX
%It will produce this file structure:
%   patients:
%       ID_1
%           fake_images (Column View with NCCT->CBV->CBF->MTT->TMAX)
%           real_images (Column View with NCCT->CBV->CBF->MTT->TMAX)
%       ID_2
%           .
%           .
%           .
%% Change Paths where appropriate

all_image_path = '';
output_path = '';

%% Connect Utilities 

current_directory = pwd();
cd("../utilities")
utilities = pwd();
cd(current_directory)
p_deident = genpath(utilities);
addpath(p_deident);

%% Import Patient Data

% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 1);

% Specify sheet and range
opts.Sheet = "Evaluation 3";
opts.DataRange = "A2:A21";

% Specify column names and types
opts.VariableNames = "patientIDs";
opts.VariableTypes = "string";

% Specify variable properties
opts = setvaropts(opts, "patientIDs", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "patientIDs", "EmptyFieldRule", "auto");

% Import the data
data_path = createPath("../utilities");
patients = readtable(strcat(data_path, 'ids.xlsx'), opts, "UseExcel", false);


% Clear temporary variables
clear opts


%% Do not edit below this point

% Check if output is a folder, if not create it 

if not(isfolder(output_path))
   mkdir(output_path) 
end


all_images = fixDir(all_image_path);

for j = 1: size(patients,1)
    cur_patient = num2str(patients{j,1});
    
    for i = 1 : length(all_images)
       image_type_path = strcat(all_images(i).folder, '\', all_images(i).name);
       image_type_folder = fixDir(image_type_path);
       image_type = all_images(i).name;
       
       blank = zeros(256,256,3);

          NCCT1 = zeros(256,256,3);NCCT2 = zeros(256,256,3);NCCT3 = zeros(256,256,3);
          NCCT4 = zeros(256,256,3);NCCT5 = zeros(256,256,3);NCCT6 = zeros(256,256,3);
          NCCT7 = zeros(256,256,3);NCCT8 = zeros(256,256,3);NCCT9 = zeros(256,256,3);
          NCCT10 = zeros(256,256,3);


          CBF1 = zeros(256,256,3);CBF2 = zeros(256,256,3);CBF3 = zeros(256,256,3);
          CBF4 = zeros(256,256,3);CBF5 = zeros(256,256,3);CBF6 = zeros(256,256,3);
          CBF7 = zeros(256,256,3);CBF8 = zeros(256,256,3);CBF9 = zeros(256,256,3);
          CBF10 = zeros(256,256,3);

          CBV1 = zeros(256,256,3);CBV2 = zeros(256,256,3);CBV3 = zeros(256,256,3);
          CBV4 = zeros(256,256,3);CBV5 = zeros(256,256,3);CBV6 = zeros(256,256,3);
          CBV7 = zeros(256,256,3);CBV8 = zeros(256,256,3);CBV9 = zeros(256,256,3);
          CBV10 = zeros(256,256,3);

          MTT1 = zeros(256,256,3);MTT2 = zeros(256,256,3);MTT3 = zeros(256,256,3);
          MTT4 = zeros(256,256,3);MTT5 = zeros(256,256,3);MTT6 = zeros(256,256,3);
          MTT7 = zeros(256,256,3);MTT8 = zeros(256,256,3);MTT9 = zeros(256,256,3);
          MTT10 = zeros(256,256,3);

          TMAX1 = zeros(256,256,3);TMAX2 = zeros(256,256,3);TMAX3 = zeros(256,256,3);
          TMAX4 = zeros(256,256,3);TMAX5 = zeros(256,256,3);TMAX6 = zeros(256,256,3);
          TMAX7 = zeros(256,256,3);TMAX8 = zeros(256,256,3);TMAX9 = zeros(256,256,3);
          TMAX10 = zeros(256,256,3);

          %% Trying to load
          try 
              NCCT1(:,:,1) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_1.bmp'))); 
              NCCT1(:,:,2) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_1.bmp')));
              NCCT1(:,:,3) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_1.bmp')));catch end;
          try 
              NCCT2(:,:,1) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_2.bmp'))); 
              NCCT2(:,:,2) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_2.bmp')));
              NCCT2(:,:,3) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_2.bmp')));catch end;
          try 
              NCCT3(:,:,1) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_3.bmp'))); 
              NCCT3(:,:,2) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_3.bmp')));
              NCCT3(:,:,3) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_3.bmp')));catch end;
          try 
              NCCT4(:,:,1) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_4.bmp'))); 
              NCCT4(:,:,2) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_4.bmp')));
              NCCT4(:,:,3) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_4.bmp'))); catch end;
          try 
              NCCT5(:,:,1) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_5.bmp'))); 
              NCCT5(:,:,2) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_5.bmp')));
              NCCT5(:,:,3) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_5.bmp'))); catch end;
          try 
              NCCT6(:,:,1) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_6.bmp'))); 
              NCCT6(:,:,2) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_6.bmp')));
              NCCT6(:,:,3) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_6.bmp'))); catch end;
          try 
              NCCT7(:,:,1) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_7.bmp'))); 
              NCCT7(:,:,2) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_7.bmp')));
              NCCT7(:,:,3) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_7.bmp'))); catch end;
          try 
              NCCT8(:,:,1) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_8.bmp'))); 
              NCCT8(:,:,2) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_8.bmp')));
              NCCT8(:,:,3) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_8.bmp'))); catch end;
          try 
              NCCT9(:,:,1) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_9.bmp'))); 
              NCCT9(:,:,2) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_9.bmp')));
              NCCT9(:,:,3) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_9.bmp'))); catch end;
          try 
              NCCT10(:,:,1) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_10.bmp'))); 
              NCCT10(:,:,2) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_10.bmp')));
              NCCT10(:,:,3) = imread(fullfile(all_image_path, "real_images" , "NCCT", strcat(cur_patient,'_10.bmp'))); catch end;

          try CBF1 = imread(fullfile(all_image_path, all_images(i).name , "CBF", strcat(cur_patient,'_1.bmp'))); catch end;
          try CBF2 = imread(fullfile(all_image_path, all_images(i).name , "CBF", strcat(cur_patient,'_2.bmp'))); catch end;
          try CBF3 = imread(fullfile(all_image_path, all_images(i).name , "CBF", strcat(cur_patient,'_3.bmp'))); catch end;
          try CBF4 = imread(fullfile(all_image_path, all_images(i).name , "CBF", strcat(cur_patient,'_4.bmp'))); catch end;
          try CBF5 = imread(fullfile(all_image_path, all_images(i).name , "CBF", strcat(cur_patient,'_5.bmp'))); catch end;
          try CBF6 = imread(fullfile(all_image_path, all_images(i).name , "CBF", strcat(cur_patient,'_6.bmp'))); catch end;
          try CBF7 = imread(fullfile(all_image_path, all_images(i).name , "CBF", strcat(cur_patient,'_7.bmp'))); catch end;
          try CBF8 = imread(fullfile(all_image_path, all_images(i).name , "CBF", strcat(cur_patient,'_8.bmp'))); catch end;
          try CBF9 = imread(fullfile(all_image_path, all_images(i).name , "CBF", strcat(cur_patient,'_9.bmp'))); catch end;
          try CBF10 = imread(fullfile(all_image_path, all_images(i).name , "CBF", strcat(cur_patient,'_10.bmp'))); catch end;

          try CBV1 = imread(fullfile(all_image_path, all_images(i).name , "CBV", strcat(cur_patient,'_1.bmp'))); catch end;
          try CBV2 = imread(fullfile(all_image_path, all_images(i).name , "CBV", strcat(cur_patient,'_2.bmp'))); catch end;
          try CBV3 = imread(fullfile(all_image_path, all_images(i).name , "CBV", strcat(cur_patient,'_3.bmp'))); catch end;
          try CBV4 = imread(fullfile(all_image_path, all_images(i).name , "CBV", strcat(cur_patient,'_4.bmp'))); catch end;
          try CBV5 = imread(fullfile(all_image_path, all_images(i).name , "CBV", strcat(cur_patient,'_5.bmp'))); catch end;
          try CBV6 = imread(fullfile(all_image_path, all_images(i).name , "CBV", strcat(cur_patient,'_6.bmp'))); catch end;
          try CBV7 = imread(fullfile(all_image_path, all_images(i).name , "CBV", strcat(cur_patient,'_7.bmp'))); catch end;
          try CBV8 = imread(fullfile(all_image_path, all_images(i).name , "CBV", strcat(cur_patient,'_8.bmp'))); catch end;
          try CBV9 = imread(fullfile(all_image_path, all_images(i).name , "CBV", strcat(cur_patient,'_9.bmp'))); catch end;
          try CBV10 = imread(fullfile(all_image_path, all_images(i).name , "CBV", strcat(cur_patient,'_10.bmp'))); catch end;

          try MTT1 = imread(fullfile(all_image_path, all_images(i).name , "MTT", strcat(cur_patient,'_1.bmp'))); catch end;
          try MTT2 = imread(fullfile(all_image_path, all_images(i).name , "MTT", strcat(cur_patient,'_2.bmp'))); catch end;
          try MTT3 = imread(fullfile(all_image_path, all_images(i).name , "MTT", strcat(cur_patient,'_3.bmp'))); catch end;
          try MTT4 = imread(fullfile(all_image_path, all_images(i).name , "MTT", strcat(cur_patient,'_4.bmp'))); catch end;
          try MTT5 = imread(fullfile(all_image_path, all_images(i).name , "MTT", strcat(cur_patient,'_5.bmp'))); catch end;
          try MTT6 = imread(fullfile(all_image_path, all_images(i).name , "MTT", strcat(cur_patient,'_6.bmp'))); catch end;
          try MTT7 = imread(fullfile(all_image_path, all_images(i).name , "MTT", strcat(cur_patient,'_7.bmp'))); catch end;
          try MTT8 = imread(fullfile(all_image_path, all_images(i).name , "MTT", strcat(cur_patient,'_8.bmp'))); catch end;
          try MTT9 = imread(fullfile(all_image_path, all_images(i).name , "MTT", strcat(cur_patient,'_9.bmp'))); catch end;
          try MTT10 = imread(fullfile(all_image_path, all_images(i).name , "MTT", strcat(cur_patient,'_10.bmp'))); catch end;

          try TMAX1 = imread(fullfile(all_image_path, all_images(i).name , "TTP", strcat(cur_patient,'_1.bmp'))); catch end;
          try TMAX2 = imread(fullfile(all_image_path, all_images(i).name , "TTP", strcat(cur_patient,'_2.bmp'))); catch end;
          try TMAX3 = imread(fullfile(all_image_path, all_images(i).name , "TTP", strcat(cur_patient,'_3.bmp'))); catch end;
          try TMAX4 = imread(fullfile(all_image_path, all_images(i).name , "TTP", strcat(cur_patient,'_4.bmp'))); catch end;
          try TMAX5 = imread(fullfile(all_image_path, all_images(i).name , "TTP", strcat(cur_patient,'_5.bmp'))); catch end;
          try TMAX6 = imread(fullfile(all_image_path, all_images(i).name , "TTP", strcat(cur_patient,'_6.bmp'))); catch end;
          try TMAX7 = imread(fullfile(all_image_path, all_images(i).name , "TTP", strcat(cur_patient,'_7.bmp'))); catch end;
          try TMAX8 = imread(fullfile(all_image_path, all_images(i).name , "TTP", strcat(cur_patient,'_8.bmp'))); catch end;
          try TMAX9 = imread(fullfile(all_image_path, all_images(i).name , "TTP", strcat(cur_patient,'_9.bmp'))); catch end;
          try TMAX10 = imread(fullfile(all_image_path, all_images(i).name , "TTP", strcat(cur_patient,'_10.bmp'))); catch end;

          CT_Column = [blank, blank, blank, blank, blank
              NCCT1, CBV1, CBF1, MTT1, TMAX1;
              NCCT2, CBV2, CBF2, MTT2, TMAX2;
              NCCT3, CBV3, CBF3, MTT3, TMAX3;
              NCCT4, CBV4, CBF4, MTT4, TMAX4;
              NCCT5, CBV5, CBF5, MTT5, TMAX5;
              NCCT6, CBV6, CBF6, MTT6, TMAX6;
              NCCT7, CBV7, CBF7, MTT7, TMAX7;
              NCCT8, CBV8, CBF8, MTT8, TMAX8;
              NCCT9, CBV9, CBF9, MTT9, TMAX9;
              NCCT10, CBV10, CBF10, MTT10, TMAX10;];
          
<<<<<<< HEAD
          CT_Column = insertText(CT_Column, [0,100], 'NCCT   CBV   CBF   MTT   TTP', 'FontSize', 80, 'BoxColor', 'black', 'TextColor', 'white');
=======
          CT_Column = insertText(CT_Column, [0,100], 'NCCT   CBV   CBF     MTT    TTP', 'FontSize', 80, 'BoxColor', 'black', 'TextColor', 'white');
>>>>>>> 94de1e00c2d645edafcdcce4f78dc33ff22a97ad
          
           if not(isfolder(fullfile(output_path, cur_patient)))
               mkdir(fullfile(output_path, cur_patient));
           end
    
          imwrite(CT_Column, fullfile(output_path, cur_patient, strcat(all_images(i).name,'.bmp')));
          
    end
end
