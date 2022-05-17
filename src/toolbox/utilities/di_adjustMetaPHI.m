function outputInfo = di_adjustMetaPHI(fileInfo,newID,birthYear,newAccessionNumber,newDate,newStudyUID)
%DI_ADJUSTMETAPHI   Adjust PHI present in DICOM metadata.
%   
% Calls to this function will adjust the content of PHI-containing metadata
% fields if they are present in the original metadata. This preserves the
% structure of the original metadata while editing all PHI data.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------

%Private tag
try
    if isfield(fileInfo, dicomlookup('0009','0400'))
        fileInfo.(dicomlookup('0009','0400')).Item_1.PatientName = newID;
        fileInfo.(dicomlookup('0009','0400')).Item_1.PatientID = newID;
        fileInfo.(dicomlookup('0009','0400')).Item_1.IssuerOfPatientID = '';
        fileInfo.(dicomlookup('0009','0400')).Item_1.PatientBirthDate = strcat(birthYear, '0101');
        fileInfo.(dicomlookup('0009','0400')).Item_1.OtherPatientIDs = newID;
        if isfield(fileInfo.(dicomlookup('0009','0400')).Item_1, 'PatientAge')
            fileInfo.(dicomlookup('0009','0400')).Item_1.PatientAge = fileInfo.PatientAge;
        end
    end
catch
end

% Source Patient Group Identification Sequence
if isfield(fileInfo, dicomlookup('0010','0026')), fileInfo.(dicomlookup('0010','0026')).Item_1.PatientID = newID; end

% Group of Patients Identification Sequence
if isfield(fileInfo, dicomlookup('0010','0027')), fileInfo.(dicomlookup('0010','0027')).Item_1.PatientID = newID; end

% Other Patient IDs
if isfield(fileInfo, dicomlookup('0010','1000')), fileInfo.(dicomlookup('0010','1000')) = newID; end

% Other Patient Names
if isfield(fileInfo, dicomlookup('0010','1001')), fileInfo.(dicomlookup('0010','1001')) = newID; end

% Scheduled Procedure Step ID
if isfield(fileInfo, dicomlookup('0040','0009'))
    fileInfo.(dicomlookup('0040','0009')) = newAccessionNumber;
end

% Referenced Request Sequence
try
    if isfield(fileInfo, dicomlookup('0040','A370'))
        fileInfo.ReferencedRequestSequence.Item_1.AccessionNumber = newAccessionNumber;
        fileInfo.ReferencedRequestSequence.Item_1.ReferencedStudySequence = '';
        fileInfo.ReferencedRequestSequence.Item_1.StudyInstanceUID = newStudyUID;
        fileInfo.(dicomlookup('0040','A370')).Item_1.(dicomlookup('0032','1060')) = '';
        fileInfo.(dicomlookup('0040','A370')).Item_1.(dicomlookup('0032','1064')) = '';
        fileInfo.(dicomlookup('0040','A370')).Item_1.(dicomlookup('0040','1001')) = newID;

    end
catch
end

% Request Attributes Sequence
try
    if isfield(fileInfo, dicomlookup('0040','0275'))
        fileInfo.RequestAttributesSequence.Item_1.ScheduledProcedureStepID = newAccessionNumber;
    end
catch
end

% Request Attributes Sequence
try
    if isfield(fileInfo, dicomlookup('0040','0275'))
        fileInfo.RequestAttributesSequence.Item_1.RequestedProcedureID = newAccessionNumber;
    end
catch
end

% Requested Procedure ID
if isfield(fileInfo, dicomlookup('0040','1001'))
    fileInfo.(dicomlookup('0040','1001')) = newAccessionNumber;
end

% Study ID
if isfield(fileInfo, dicomlookup('0020','0010'))
    fileInfo.(dicomlookup('0020','0010')) = newAccessionNumber;
end

% Acquisition Date
if isfield(fileInfo, dicomlookup('0008','0022'))
    fileInfo.(dicomlookup('0008','0022')) = newDate;
end

% Content Date
if isfield(fileInfo, dicomlookup('0008','0023'))
    fileInfo.(dicomlookup('0008','0023')) = newDate;
end

% Scheduled Procedure StepStart Date
if isfield(fileInfo, dicomlookup('0040','0002'))
    fileInfo.(dicomlookup('0040','0002')) = newDate;
end

% Scheduled Procedure StepEnd Date
if isfield(fileInfo, dicomlookup('0040','0004'))
    fileInfo.(dicomlookup('0040','0004')) = newDate;
end

% Scheduled Performing Procedure Step ID
if isfield(fileInfo, dicomlookup('0040','0009'))
    fileInfo.(dicomlookup('0040','0009')) = newAccessionNumber;
end

% Performed Procedure StepStart Date
if isfield(fileInfo, dicomlookup('0040','0244'))
    fileInfo.(dicomlookup('0040','0244')) = newDate;
end

% Performed Procedure StepEnd Date
if isfield(fileInfo, dicomlookup('0040','0250'))
    fileInfo.(dicomlookup('0040','0250')) = newDate;
end

% Performed Performing Procedure Step ID
if isfield(fileInfo, dicomlookup('0040','0253'))
    fileInfo.(dicomlookup('0040','0253')) = newAccessionNumber;
end

% Observation DateTime
if isfield(fileInfo, dicomlookup('0040','A032'))
    fileInfo.(dicomlookup('0040','A032')) = newDate;
end

% UID
if isfield(fileInfo, dicomlookup('0040','A124'))
    fileInfo.(dicomlookup('0040','A124')) = newAccessionNumber;
end

% Content Date
if isfield(fileInfo, dicomlookup('0008','0023'))
    fileInfo.(dicomlookup('0008','0023')) = newDate;
end

% Verifying Observer Sequence
try
    if isfield(fileInfo, dicomlookup('0040','A073'))
        fileInfo.VerifyingObserverSequence.Item_1.VerificationDateTime = newDate;
    end
catch
end

% Content Sequence
try
    if isfield(fileInfo, dicomlookup('0040','A730'))
        fileInfo.ContentSequence.Item_4.DateTime = newDate;
        fileInfo.ContentSequence.Item_5.DateTime = newDate;
    end
catch
end

outputInfo=fileInfo;
end

