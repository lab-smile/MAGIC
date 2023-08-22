function di_img = di_rmPerfMapPHI(orig_img)
%DI_RMPERFMAPPHI   Remove PHI present in Perfusion Maps of a given 
%                  CT DICOM series.
%   
% Calls to this function will blackout annotated PHI information on the
% perfusion map of a given CT DICOM series. This PHI is stored in pixel 
% data, not the metadata.
%
% NOTE: This function assumes that the image dimensions for this type of
% perfusion map is 1024px x 1536px.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------


idx = size(orig_img,3); % Account for both RGB and grayscale images

% Top left
orig_img(1:35,1:140,1:idx) = 0;
orig_img(30:90,1:90,1:idx) = 0;
orig_img(1:30,300:512,1:idx) = 0;

% Top middle
orig_img(1:35,513:652,1:idx) = 0;
orig_img(30:90,513:602,1:idx) = 0;
orig_img(1:30,812:1024,1:idx) = 0;

% Top right
orig_img(1:35,1025:1164,1:idx) = 0;
orig_img(30:90,1025:1114,1:idx) = 0;
orig_img(1:30,1324:1536,1:idx) = 0;

% Bottom left
orig_img(513:547,1:140,1:idx) = 0;
orig_img(542:602,1:90,1:idx) = 0;
orig_img(513:542,300:512,1:idx) = 0;

% Bottom middle
orig_img(513:547,513:652,1:idx) = 0;
orig_img(542:602,513:602,1:idx) = 0;
orig_img(513:542,812:1024,1:idx) = 0;

% Bottom right
orig_img(513:547,1025:1164,1:idx) = 0;
orig_img(542:602,1025:1114,1:idx) = 0;
orig_img(513:542,1324:1536,1:idx) = 0;


di_img = orig_img;
end

