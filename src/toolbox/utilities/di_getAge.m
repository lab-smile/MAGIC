function [birthYear,age_PHI_check] = di_getAge(fileInfo,age_PHI_cutoff)
%DI_RMMETAPHI   Get patient age from DICOM metadata.
%   
% Calls to this function will get the patient's age from the DICOM metadata
% by checking the PatientBirthDate and the PatientAge metadata fields. If
% neither of these fields are present, a default birthYear of '0000' is
% assigned.
%
% AGE_PHI_CUTOFF = The patient age at which all older ages are considered
%                  PHI. If the patient's age is greater than the cutoff,
%                  this information is recorded and used in subsequent
%                  functions. This value can be adjusted in the settings
%                  section of the main script.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------

age_PHI_check = 0;

if isfield(fileInfo,'StudyDate')
    studyYear = str2num(fileInfo.StudyDate(1:4));
else
    time = clock;
    studyYear = time(1);
end

if isfield(fileInfo,'PatientBirthDate')
    birthDateExists = ~isempty(fileInfo.PatientBirthDate);
end

if isfield(fileInfo,'PatientAge')
    patientAgeExists = ~isempty(fileInfo.PatientAge);
end

if isfield(fileInfo,'PatientBirthDate') && birthDateExists
    birthYear = str2num(fileInfo.PatientBirthDate(1:4));    
    
    if studyYear-birthYear >= age_PHI_cutoff
        age_PHI_check = 1;
        birthYear = num2str(studyYear - age_PHI_cutoff);
    else
        birthYear = num2str(birthYear);
    end
    

elseif isfield(fileInfo,'PatientAge') && patientAgeExists
    age_orig = fileInfo.PatientAge;
    while isnan(str2double(age_orig))
        age_orig=age_orig(1:end-1);
    end
    age_orig = str2num(age_orig);
    
    if age_orig >= age_PHI_cutoff
        age_PHI_check = 1;
        birthYear = num2str(studyYear-age_PHI_cutoff);
    else
        birthYear = num2str(studyYear-age_orig);
    end
    
else
    birthYear = '0000';
    age_PHI_check = 1;
end

end

