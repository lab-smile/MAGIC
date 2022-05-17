function collage = make_collage(input_path, output_path)
%% Given a folder with 10 z-slice locations indicated by ID_slice.bmp, will make a collage of the 10 images and output into the output_path folder.
% Looks for a unique ID within the modalitity folder that is passed in, in
% input_path. Since each patient will have 10 photos, it will then create
% the collage assuming the file name is ID_slice.bmp.

%% Change Path
p_deident = genpath('C:/Users/Simon Kato/Desktop/Research/REU/scripts/utilities/');

%% Do not edit below
addpath(p_deident);

numPatients = 62;
patients = importdata("patient_test.xlsx");

for i = 1 : numPatients
    curPatient = patients{i};
    
    try
        image_2 = imread(strcat(input_path,'\',curPatient,'_2.bmp'));
    catch
        image_2 = uint8(zeros(256,256,3));
    end
    
    try
        image_1 = imread(strcat(input_path,'\',curPatient,'_1.bmp'));
    catch
        image_1 = uint8(zeros(size(image_2)));
    end
    try
        image_3 = imread(strcat(input_path,'\',curPatient,'_3.bmp'));
    catch
        image_3 = uint8(zeros(size(image_2)));
    end
    try
        image_4 = imread(strcat(input_path,'\',curPatient,'_4.bmp'));
    catch
        image_4 = uint8(zeros(size(image_2)));
    end
    try
        image_5 = imread(strcat(input_path,'\',curPatient,'_5.bmp'));
    catch
        image_5 = uint8(zeros(size(image_2)));
    end
    try
        image_6 = imread(strcat(input_path,'\',curPatient,'_6.bmp'));
    catch
        image_6 = uint8(zeros(size(image_2)));
    end
    try
        image_7 = imread(strcat(input_path,'\',curPatient,'_7.bmp'));
    catch
        image_7 = uint8(zeros(size(image_2)));
    end
    try
        image_8 = imread(strcat(input_path,'\',curPatient,'_8.bmp'));
    catch
        image_8 = uint8(zeros(size(image_2)));
    end
    try
        image_9 = imread(strcat(input_path,'\',curPatient,'_9.bmp'));
    catch
        image_9 = uint8(zeros(size(image_2)));
    end
    try
        image_10 = imread(strcat(input_path,'\',curPatient,'_10.bmp'));
    catch
        image_10 = uint8(zeros(size(image_2)));
    end
    
    blank = uint8(zeros(size(image_2)));
    collage = [[blank, image_1, image_2, image_3]; [image_4, image_5, image_6, image_7]; [image_8, image_9, image_10, blank]];
    
    imwrite(collage, strcat(output_path, '\', curPatient, '_collage.bmp'));
end
end