function outputInfo = di_adjustDoseRptPHI(fileInfo,UID_root)
%DI_ADJUSTDOSERPTPHI   Edit & remove PHI metadata fields in the X-Ray
%                      radiation dose report of a given CT DICOM series.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------
studyUID = fileInfo.StudyInstanceUID;
if isfield(fileInfo,'StudyDate')
    studyDate = fileInfo.StudyDate;
else
    studyDate = '00000000';
end
if isfield(fileInfo,'StudyTime')
    
    studyTime = fileInfo.StudyTime;
else
    studyTime = '00000000';
end

outputInfo = fileInfo;
if isfield(outputInfo,'ContentSequence')
    outputInfo = di_adjustContentSeq(outputInfo,UID_root,studyDate,studyTime,studyUID);
end
end

