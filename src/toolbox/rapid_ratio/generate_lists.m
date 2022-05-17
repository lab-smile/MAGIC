function list = generate_lists(datasetPath, outputFile)
%% Function Header
% Description:
%   Generates a two indicators lists for whether the subjects in the datasetPath
%   have any amount of infarct core or tissue at risk determined by the
%   Rapid CBF Mismatch. The indicator lists are saved into the outputFile
%
% Comments:
%   It is expected that datasetPath is composed of patients with Rapid and
%   as such WILL have a CBF mismatch image. If you don't have patients with
%   only Rapid, there are scripts under evaluation > RAPID that will
%   perform this task on deidentified data and identfied data (the fastest
%   runs on deidentified data)
%
% Inputs:
%   datasetPath : path to dataset with patients, importantly, structure of
%       the patients within the dataset must follow the structure outputted by
%       the deidentified code. This structure is discussed in the main README
%       of the github repo.
%
%   outputFile : The name of the file which will contain the lists composed
%       of patientIDs and indicators for infarct core or tissue at risk. 
%       Only absolute path names for outputFile will be accepted. For best 
%       results, verify that the extension of outputFile is .xlsx
%
% Output:
%   Table with patientIDs and two columns for indicating whether infarct
%   core is present in a given patient and whether tissue at risk is
%   present in a given patient respectively.
%
% Written by : Simon Kato
%              Smile-LAB @UF
%% Function

%% Add utilitie functions to the path
current_directory = pwd();
cd("../utilities")
utilities = pwd();
cd(current_directory)

p_deident = genpath(utilities);
addpath(p_deident);


%% Find all ratios
datasetPath = createPath(datasetPath);

if ~strcmp(datasetPath(end),'/')
    datasetPath = [datasetPath '/'];
end

if strcmp(outputFile, "")
    outputFile = "lists.xlsx";
end

if strcmp(outputFile(end),'/')
    strcat(outputFile, "lists.xlsx");
end

patients = dir(datasetPath);
patients = fixDir(patients);

patientIDs = strings(length(patients), 1);
list = zeros(length(patients), 2);

for i = 1: length(patients)
    
    patient = patients(i);
    tempDirs = dir(fullfile(datasetPath, '/' , patient.name));
    
    patientIDs(i) = patient.name;

    tempDirs = fixDir(tempDirs);
    tempDir = tempDirs(1);
    
    subDirs = dir(fullfile(datasetPath, '/', patient.name, '/', tempDir.name));
    subDirs = fixDir(subDirs);
    
    for j = 1 : length(subDirs)
        tempName = subDirs(j).name;
        tempName = replace(tempName,' ','_');
         if strcmp(tempName, 'RAPID_CT-P_Summary')
            files = dir(fullfile(datasetPath, patient.name, '/', tempDir.name, '/', subDirs(j).name));
            files = fixDir(files);

            for fileNum = 1 : length(files)
                curFile = strcat(datasetPath, patient.name, '/', tempDir.name, '/', subDirs(j).name, '/', files(fileNum).name);
                fileIm = dicomread(fullfile(curFile));
                
                if(size(fileIm) == [1283, 2048, 3])
                   [patientTr, patientIc] = get_lists(fileIm); 
                   list(i,1) = patientTr; list(i,2) = patientIc;
                end
            end
         end
    end
end

outputTable = table(patientIDs, list);

writetable(outputTable, outputFile)
end
