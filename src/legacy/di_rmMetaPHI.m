function outputInfo = di_rmMetaPHI(fileInfo)
%DI_RMMETAPHI   Remove PHI present in DICOM metadata.
%   
% Calls to this function will remove the content of PHI-containing metadata
% fields if they are present in the original metadata. This preserves the
% structure of the original metadata while removing all PHI data.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------

%Referring Physician's Name
if isfield(fileInfo, dicomlookup('0008','0090')), fileInfo.(dicomlookup('0008','0090')) = ''; end

%Referring Physician's Address
if isfield(fileInfo, dicomlookup('0008','0092')), fileInfo.(dicomlookup('0008','0092')) = ''; end

%Referring Physician's Telephone Number
if isfield(fileInfo, dicomlookup('0008','0094')), fileInfo.(dicomlookup('0008','0094')) = ''; end

% Referring Physician Identification Sequence
try
    if isfield(fileInfo, dicomlookup('0008','0096'))
        fileInfo = di_rmIdentSeq(fileInfo,'0008','0096');
    end
catch
end

%Consulting Physician's Name
if isfield(fileInfo, dicomlookup('0008','009C')), fileInfo.(dicomlookup('0008','009C')) = ''; end

% Consulting Physician Identification Sequence
try
    if isfield(fileInfo, dicomlookup('0008','009D'))
        fileInfo = di_rmIdentSeq(fileInfo,'0008','009D');
    end
catch
end

% Physicians of Record
if isfield(fileInfo, dicomlookup('0008','1048')), fileInfo.(dicomlookup('0008','1048')) = ''; end

% Physicians of Record Identification Sequence
try
    if isfield(fileInfo, dicomlookup('0008','1049'))
        fileInfo = di_rmIdentSeq(fileInfo,'0008','1049');
    end
catch
end

% Performing Physician's Name
if isfield(fileInfo, dicomlookup('0008','1050')), fileInfo.(dicomlookup('0008','1050')) = ''; end

% Performing Physician Identification Sequence
try
    if isfield(fileInfo, dicomlookup('0008','1052'))
        fileInfo = di_rmIdentSeq(fileInfo,'0008','1052');
    end
catch
end

% Name of Physician Reading Study
if isfield(fileInfo, dicomlookup('0008','1060')), fileInfo.(dicomlookup('0008','1060')) = ''; end

% Physicians Reading Study Identification Sequence
try
    if isfield(fileInfo, dicomlookup('0008','1062'))
        fileInfo = di_rmIdentSeq(fileInfo,'0008','1062');
    end
catch
end

% Operator's Name
if isfield(fileInfo, dicomlookup('0008','1070')), fileInfo.(dicomlookup('0008','1070')) = ''; end

% Operator Identification Sequence
try
    if isfield(fileInfo, dicomlookup('0008','1072'))
        fileInfo = di_rmIdentSeq(fileInfo,'0008','1072');
    end
catch
end

% Patient Birth Time
if isfield(fileInfo, dicomlookup('0010','0032')), fileInfo.(dicomlookup('0010','0032')) = ''; end

% Patient's Birth Date in Alternative Calendar
if isfield(fileInfo, dicomlookup('0010','0033')), fileInfo.(dicomlookup('0010','0033')) = ''; end

% Patient's Death Date in Alternative Calendar
if isfield(fileInfo, dicomlookup('0010','0034')), fileInfo.(dicomlookup('0010','0034')) = ''; end

% Patient's Alternative Calendar
if isfield(fileInfo, dicomlookup('0010','0035')), fileInfo.(dicomlookup('0010','0035')) = ''; end

% Other Patient IDs Sequence
try
    if isfield(fileInfo, dicomlookup('0010','1002'))
        fileInfo.(dicomlookup('0010','1002')) = [];
    end
catch
end

% Patient's Address
if isfield(fileInfo, dicomlookup('0010','1040')), fileInfo.(dicomlookup('0010','1040')) = ''; end

% Patient's Mother's Name
if isfield(fileInfo, dicomlookup('0010','1060')), fileInfo.(dicomlookup('0010','1060')) = ''; end

% Military Rank
if isfield(fileInfo, dicomlookup('0010','1080')), fileInfo.(dicomlookup('0010','1080')) = ''; end

% Branch of Service
if isfield(fileInfo, dicomlookup('0010','1081')), fileInfo.(dicomlookup('0010','1081')) = ''; end

% Country of Residence
if isfield(fileInfo, dicomlookup('0010','2150')), fileInfo.(dicomlookup('0010','2150')) = ''; end

% Region of Residence
if isfield(fileInfo, dicomlookup('0010','2152')), fileInfo.(dicomlookup('0010','2152')) = ''; end

% Patient's Telephone Numbers
if isfield(fileInfo, dicomlookup('0010','2154')), fileInfo.(dicomlookup('0010','2154')) = ''; end

% Patient's Telecom Information
if isfield(fileInfo, dicomlookup('0010','2155')), fileInfo.(dicomlookup('0010','2155')) = ''; end

% Patient's Occupation
if isfield(fileInfo, dicomlookup('0010','2180')), fileInfo.(dicomlookup('0010','2180')) = ''; end

% Scheduled Performing Procedure Physician's Name
if isfield(fileInfo, dicomlookup('0040','0006')), fileInfo.(dicomlookup('0040','0006')) = ''; end

% Requesting Physician
if isfield(fileInfo, dicomlookup('0032','1032')), fileInfo.(dicomlookup('0032','1032')) = ''; end

% Requesting Physician Identification Sequence
try
    if isfield(fileInfo, dicomlookup('0032','1031'))
        fileInfo = di_rmIdentSeq(fileInfo,'0032','1031');
    end
catch
end

outputInfo=fileInfo;
end

