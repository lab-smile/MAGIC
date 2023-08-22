function correctDir = di_fixDir(tempDir)
%DI_FIXDIR   Remove hidden & root directories from the list of
%            subdirectories that are being processed.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------

for tempIndex = length(tempDir):-1:1
    name = tempDir(tempIndex).name;
    if strcmp(name(1),'.')
        tempDir(tempIndex) = [];
    end
end
correctDir = tempDir;
end
