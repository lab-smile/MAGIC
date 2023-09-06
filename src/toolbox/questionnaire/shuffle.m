%% Shuffle Driver
%   Shuffle assumes the structure created in separate_patients.
%   Shuffle will go into each patients and rename fake and real_images to
%   CTP_0 and CTP_1 according to an assignment that is generated at random
%   with the rng seed 0.
%
%   The mapping of real and fake images is saved into an excel file that is
%   put wherever the script is run.
%
%   Notably, the mapping sends the first numerically sorted folder in the
%   patients folder and has the mapping under line 1. Line 2 has the second
%   folder in the patients folder. Since the patients IDs have no ties and
%   are sorted, there is no risk of confusion.
%% Change Paths where appropriate
p_deident = genpath('C:\Users\skato1\Desktop\REU\scripts\utilities');
addpath(p_deident);

input = 'C:\Users\skato1\Desktop\REU\data\evaluation_3';
output = 'C:\Users\skato1\Desktop\REU\data\evaluation_3_final';
patients = fix_dir(input);

%% Check if output is a folder, if not create it 

if not(isfolder(output))
   mkdir(output) 
end

mkdir(fullfile(output, "CTP0"))
mkdir(fullfile(output, "CTP1"))

%% Create First Mapping (split data in half)
rng(8500);
real_assignments = randi(2,length(patients),1)-1;
predicted_assignments = abs(real_assignments - ones(length(patients),1));

%% Rename the folders according to the mapping created
patientIDs = [];

for i = 1 : length(patients)
   curPatient = fix_dir(fullfile(patients(i).folder, patients(i).name));
   patientIDs = [patientIDs; patients(i).name];
   movefile(fullfile(patients(i).folder, patients(i).name,'fake_images.bmp'), fullfile(patients(i).folder, patients(i).name, strcat('CTP_',int2str(predicted_assignments(i)),'.bmp')));
   movefile(fullfile(patients(i).folder, patients(i).name,'real_images.bmp'), fullfile(patients(i).folder, patients(i).name, strcat('CTP_',int2str(real_assignments(i)),'.bmp')));
end

%% Output to Excel File
Mapping = table(patientIDs, real_assignments, predicted_assignments);

writetable(Mapping, '01mapping.xlsx')

%% Create Permutation of CTP_0's 
rng(10);
CTP0_patients = [];

for i = 1:length(patients)
    CTP0_patients = [CTP0_patients; strcat(patients(i).name, '_0')];
end
CTP0_patients = string(CTP0_patients);
permuted_assignments = randperm(length(CTP0_patients))';

%% Rename the folders according to the mapping created

for i = 1: length(CTP0_patients)
    curPatientInfo = char(CTP0_patients(i));
    curPatient = curPatientInfo(1:8);
    copyfile(fullfile(input,curPatient, 'CTP_0.bmp'), fullfile(output, "CTP0", strcat('CTP_',num2str(permuted_assignments(i)),'.bmp')));
end

%% Output to Excel File
Mapping = table(CTP0_patients, permuted_assignments);

writetable(Mapping, 'CTP0_permuted_mapping.xlsx')

%% Create Mapping
rng(31);
CTP1_patients = [];

for i = 1:length(patients)
    CTP1_patients = [CTP1_patients; strcat(patients(i).name, '_1')];
end
CTP1_patients = string(CTP1_patients);
permuted_assignments = randperm(length(CTP1_patients))';

%% Rename the folders according to the mapping created

for i = 1: length(CTP1_patients)
    curPatientInfo = char(CTP1_patients(i));
    curPatient = curPatientInfo(1:8);
    copyfile(fullfile(input,curPatient, 'CTP_1.bmp'), fullfile(output, "CTP1", strcat('CTP_',num2str(permuted_assignments(i)),'.bmp')));
end
%% Output to Excel File
Mapping = table(CTP1_patients, permuted_assignments);

writetable(Mapping, 'CTP1_permuted_mapping.xlsx')

