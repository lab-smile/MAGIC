function [studyDescription,seriesDescription] = di_getDescription(fileInfo,newID)
%DI_GETDESCRIPTION   Get studyDescription and seriesDescription variables
%                    from the DICOM metadata structure.
%   
% Calls to this function will edit invalid characters to avoid errors in
% file naming. Additionally, this function will assign an UNTITILED name in
% cases where the seriesDescription or studyDescription metadata fields are
% either empty or not present.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------

if isnumeric(newID)
    newID = num2str(newID);
end
try
    if ~isempty(fileInfo.StudyDescription)
        studyDescription = fileInfo.StudyDescription;  % Used to sort folders
    else
        studyDescription = strcat('Untitled_',newID);
    end
catch
    studyDescription = strcat('Untitled_',newID);
end

try
    if ~isempty(fileInfo.SeriesDescription)
        seriesDescription = fileInfo.SeriesDescription;  % Used to sort folders
    else
        seriesDescription = strcat('Untitled_',newID);
    end
catch
    seriesDescription = strcat('Untitled_',newID);
end

invalid = '<>:"/\|?*';
badseries = ismember(invalid,seriesDescription);
badstudy = ismember(invalid,studyDescription);
if any(badseries)
    badchars = invalid(badseries);
    for i = 1:length(badchars)
        badchar = badchars(i);
        seriesDescription = strrep(seriesDescription,badchar,'-');
    end
end
if any(badstudy)
    badchars = invalid(badstudy);
    for i = 1:length(badchars)
        badchar = badchars(i);
        studyDescription = strrep(studyDescription,badchar,'-');
    end
end
        
        
end

