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
current_directory = pwd();
cd("../utilities")
utilities = pwd();
cd(current_directory)

p_deident = genpath(utilities);
addpath(p_deident);

input = 'C:\Users\skato1\Desktop\REU\data\small_test';
output = 'C:\Users\skato1\Desktop\REU\data\small_test_final';
patients = fixDir(input);
%% Check if output is a folder, if not create it 

if not(isfolder(output))
   mkdir(output) 
end

%% Create Mapping
rng(23);
all_patients = [];

for i = 1:5
    all_patients = [all_patients; strcat(patients(i).name, '_real'); strcat(patients(i).name,'_fake')];
end
all_patients = string(all_patients);
permuted_assignments = randperm(length(all_patients))';

%% Rename the folders according to the mapping created

for i = 1: length(all_patients)
    curPatientInfo = char(all_patients(i));
    curPatient = curPatientInfo(1:8);
    curPatientTruth = curPatientInfo(10:13);
    copyfile(fullfile(input,curPatient, strcat(curPatientTruth,'_images.bmp')), fullfile(output, strcat('CTP_',num2str(permuted_assignments(i)),'.bmp')));
end

%% Output to Excel File
Mapping = table(all_patients, permuted_assignments);

writetable(Mapping, 'permuted_mapping.xlsx')