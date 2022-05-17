function outputInfo = di_writePriv(fileInfo,ImClassStore,ImVerStore)
%DI_WRITEPRIV    Write original implementation class UID and implementation
%                version name to unique private DICOM fields.
%   
% By default, these values are stored under the tags (0x00090012) and 
% (0x00090013). The other fields are backups in case the original fields
% are filled.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------

if ~isfield(fileInfo, dicomlookup('0009','0012')) && ~isfield(fileInfo, dicomlookup('0009','0013'))
    fileInfo.(dicomlookup('0009','0012')) = ImClassStore;
    fileInfo.(dicomlookup('0009','0013')) = ImVerStore;
elseif ~isfield(fileInfo, dicomlookup('0011','0012')) && ~isfield(fileInfo, dicomlookup('0011','0013'))
    fileInfo.(dicomlookup('0011','0012')) = ImClassStore;
    fileInfo.(dicomlookup('0011','0013')) = ImVerStore;
else
    fileInfo.(dicomlookup('0013','0012')) = ImClassStore;
    fileInfo.(dicomlookup('0013','0013')) = ImVerStore;
end

outputInfo=fileInfo;
end

