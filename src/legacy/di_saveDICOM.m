function [] = di_saveDICOM(fileImage,fileInfo,filePath)
%DI_SAVEDICOM    Write the deidentified DICOM image and metadata to its new
%                new path in the designated output folder.
%   
% Calls to this function will delete private metadata fields (unless 
% previously designated as an exception) and save the new DICOM image and
% metadata. This removes the need to identify PHI in private fields, and
% this removes errors caused by private fields that are of incorrect types.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------

saveName = strcat(filePath,'.dcm');

try
    dicomwrite(fileImage,saveName,fileInfo,'CreateMode',...
        'copy','WritePrivate',true,'CompressionMode','JPEG lossless');
catch
    infofields = fields(fileInfo);
    rmpriv = startsWith(infofields,'Private');
    rmpriv = and(rmpriv,~contains(infofields,'Private_0009'));
    rmpriv = and(rmpriv,~contains(infofields,'Private_0011'));
    rmpriv = and(rmpriv,~contains(infofields,'Private_0013'));
    fileInfo = rmfield(fileInfo,infofields(rmpriv));
    
    gen_count = 0; err_count = 0;
    while gen_count == err_count
        try
            dicomwrite(fileImage,saveName,fileInfo,'CreateMode',...
                'copy','WritePrivate',true,'CompressionMode','JPEG lossless');
        catch MException
            err_count = err_count+1;
            grp = MException.message(12:15);
            el = MException.message(17:20);
            if ~isnan(str2double(grp)) && ~isnan(str2double(el))
                if isfield(fileInfo,dicomlookup(grp,el))
                    fileInfo = rmfield(fileInfo,(dicomlookup(grp,el)));
                end
            end
        end
        gen_count = gen_count+1;
    end
end
end
