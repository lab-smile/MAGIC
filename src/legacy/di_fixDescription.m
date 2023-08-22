function [studyDescription_fixed,seriesDescription_fixed] = di_fixDescription(studyDescription,seriesDescription)
%DI_FIXDESCRIPTION   Fix naming mistakes in the studyDescription and
%                    seriesDescription variables.
%   
% This function fixes mistakes in the naming of files within the same
% series that are given different series descriptions. Specifically, if a
% file is named in the format SERIESDESCRIPTION.INSTANCENUMBER, calls to
% this function will remove the .INSTANCENUMBER portion of the name.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------

studyDescription_fixed = studyDescription;
seriesDescription_fixed = seriesDescription;

if ~contains(seriesDescription,'Untitled')
    if ~isnan(str2double(seriesDescription(end)))
        endidx = 0;
        while ~isnan(str2double(seriesDescription(end-endidx)))
            endidx = endidx+1;
        end
        if ~(endidx == 1 && str2double(seriesDescription(end)) == 0)
            seriesDescription_fixed = seriesDescription(1:(end-endidx-1));
        else
            seriesDescription_fixed = seriesDescription;
        end
    end
end

if ~contains(studyDescription,'Untitled')
    if ~isnan(str2double(studyDescription(end)))
        endidx = 0;
        while ~isnan(str2double(studyDescription(end-endidx)))
            endidx = endidx+1;
        end
        if ~(endidx == 1 && str2double(studyDescription(end)) == 0)
            studyDescription_fixed = studyDescription(1:(end-endidx-1));
        else
            studyDescription_fixed = studyDescription;
        end
    end
end
end
