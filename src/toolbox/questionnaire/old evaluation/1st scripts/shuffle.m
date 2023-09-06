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
p_deident = genpath('C:/Users/Simon Kato/Desktop/Research/REU/scripts/utilities/');
addpath(p_deident);

input = 'C:\Users\skato1\Desktop\REU\data\patients_filter';
patients = fix_dir(input);
%% Create Mapping
rng(23);
real_assignments = randi(2,length(patients),1)-1;
predicted_assignments = abs(real_assignments - ones(length(patients),1));

%% Rename the folders according to the mapping created
patientIDs = [];

for i = 1 : length(patients)
   curPatient = fix_dir(fullfile(patients(i).folder, patients(i).name));
   patientIDs = [patientIDs; patients(i).name];
   movefile(fullfile(patients(i).folder, patients(i).name,'fake_images'), fullfile(patients(i).folder, patients(i).name, strcat('CTP_',int2str(predicted_assignments(i)))));
   movefile(fullfile(patients(i).folder, patients(i).name,'real_images'), fullfile(patients(i).folder, patients(i).name, strcat('CTP_',int2str(real_assignments(i)))));
end

%% Output to Excel File
Mapping = table(patientIDs, real_assignments, predicted_assignments);

writetable(Mapping, 'mapping.xlsx')