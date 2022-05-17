function correctDir = fixDir(tempDir)
%----------------------------------------
% Created by Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
% Dr. Ruogu Fang
% 6/1/2020
%----------------------------------------
%Description: Gets rid of hidden files which the dir function creates
%returns a struct with only non-hidden files
%
%Input: Path to tempDir or the struct which dir(tempDir) creates
%
%Output: Returns a Struct which contains non-hidden files

if ischar(tempDir)
    tempDir = dir(tempDir);
end

tempLength = length(tempDir);
    for tempIndex = 1 : tempLength - 1
        if tempDir(tempLength - tempIndex).name(1) == '.'
            tempDir(tempLength - tempIndex) = [];
        end
    end
    correctDir = tempDir;
end