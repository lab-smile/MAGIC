function ratios = generate_ratios(datasetPath, outputFile)
%% Function Header
% Description:
%   Finds the ratios of infarct core to tissue at risk determined by the
%   Rapid CBF Mismatch which is a surgote for the two regions for every
%   patient in datasetPath. The ratios and their corresponding patientID
%   are printed to outputFile.
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
%   outputFile : The name of the file which will contain the table composed
%       of patientIDs and their maximum ratio. Only absolute path names for
%       outputFile will be accepted. For best results, assert that the
%       extension of outputFile is .xlsx
%
% Output:
%   Table with patientIDs and their corresponding maximum ratio across 14
%       z-slices. This table will be saved to the location specified in
%       outputFile.
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
    outputFile = "ratios.xlsx";
end

if strcmp(outputFile(end),'/')
    strcat(outputFile, "ratios.xlsx");
end

patients = dir(datasetPath);
patients = fixDir(patients);

patientIDs = strings(length(patients), 1);
ratios = zeros(length(patients), 1);

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
                   ratio = get_ratio(fileIm); 
                   ratios(i) = ratio;
                end
            end
         end
    end
end

outputTable = table(patientIDs, ratios);

writetable(outputTable, outputFile)
end
