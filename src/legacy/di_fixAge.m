function outputInfo = di_fixAge(fileInfo,age_PHI_cutoff,age_PHI_check,birthYear)
%DI_FIXAGE   Edit patient age and birth date in DICOM metadata.
%   
% If the patient's age is considered PHI, this function will edit the
% PatientAge DICOM metadata field to remove sensitive information.
% Additionally, this function assigns the new birthdate to the
% PatientBirthDate DICOM metadata field.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------

if isfield(fileInfo,'PatientAge')
    if age_PHI_check && str2num(birthYear)~=0
        fileInfo.PatientAge = strcat(num2str(age_PHI_cutoff),'Y');
    end
end

if isfield(fileInfo,'PatientBirthDate')
    fileInfo.PatientBirthDate = strcat(birthYear, '0101');
end
outputInfo = fileInfo;
end

