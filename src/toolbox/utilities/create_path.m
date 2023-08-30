function absolutePath = createPath(relativePath)
%----------------------------------------
% Created by Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
% Dr. Ruogu Fang
% 6/1/2020
%----------------------------------------
%Description: Generates absolute path from a relative path
%
%Input : relative path to destination
%
%Output: absolute path to destination

curDir = cd();

cd(relativePath);
absolutePath = strcat(pwd(),'\');
cd(curDir);
end