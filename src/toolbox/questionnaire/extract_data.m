%%
%Description:
%   Extracts all the data from questionaires into a Cell called Data
%
%
% Written by : Simon Kato
%              Smile-LAB @UF
%% Edit paths, p_deidenty is the path to the utilities folder

results1 = './results/eval 3/Trial1';
results2 = './results/eval 3/Trial2';

%% Do not edit below this point

% Load Utilities 
current_directory = pwd();
cd("../utilities")
utilities = pwd();
cd(current_directory)
p_deident = genpath(utilities);
addpath(p_deident);


% Import excel sheets
opts = spreadsheetImportOptions("NumVariables", 3);

% Specify sheet and range
opts.Sheet = "Sheet1";
opts.DataRange = "A2:C21";

% Specify column names and types
opts.VariableNames = ["patientIDs", "real_assignments", "predicted_assignments"];
opts.VariableTypes = ["string", "double", "double"];

% Specify variable properties
opts = setvaropts(opts, "patientIDs", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "patientIDs", "EmptyFieldRule", "auto");

% Import the data
mapping = readtable("C:\Users\skato1\Desktop\REU\scripts\questionaire\01mapping.xlsx", opts, "UseExcel", false);


%% Clear temporary variables
clear opts

%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 2);

% Specify sheet and range
opts.Sheet = "Sheet1";
opts.DataRange = "A2:B21";

% Specify column names and types
opts.VariableNames = ["CTP0_patients", "permuted_assignments"];
opts.VariableTypes = ["string", "double"];

% Specify variable properties
opts = setvaropts(opts, "CTP0_patients", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "CTP0_patients", "EmptyFieldRule", "auto");

% Import the data
trial1map = readtable("C:\Users\skato1\Desktop\REU\scripts\questionaire\CTP0_permuted_mapping.xlsx", opts, "UseExcel", false);

%% Clear temporary variables
clear opts

%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 2);

% Specify sheet and range
opts.Sheet = "Sheet1";
opts.DataRange = "A2:B21";

% Specify column names and types
opts.VariableNames = ["CTP1_patients", "permuted_assignments"];
opts.VariableTypes = ["string", "double"];

% Specify variable properties
opts = setvaropts(opts, "CTP1_patients", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "CTP1_patients", "EmptyFieldRule", "auto");

% Import the data
trial2map = readtable("C:\Users\skato1\Desktop\REU\scripts\questionaire\CTP1_permuted_mapping.xlsx", opts, "UseExcel", false);

%% Clear temporary variables
clear opts


%% Import Data
opts = spreadsheetImportOptions("NumVariables", 14);

% Specify sheet and range
opts.Sheet = "Sheet1";
opts.DataRange = "A2:N21";

% Specify column names and types
opts.VariableNames = ["Var1", "Question1", "Var3", "Question2A", "Var5", "Question2B", "Var7", "Question2C", "Var9", "Question2D", "Var11", "Question3", "Var13", "Question4"];
opts.SelectedVariableNames = ["Question1", "Question2A", "Question2B", "Question2C", "Question2D", "Question3", "Question4"];
opts.VariableTypes = ["char", "double", "char", "double", "char", "double", "char", "double", "char", "double", "char", "double", "char", "double"];

% Specify file level properties
opts.ImportErrorRule = "omitrow";
opts.MissingRule = "omitrow";

% Specify variable properties
opts = setvaropts(opts, ["Var1", "Var3", "Var5", "Var7", "Var9", "Var11", "Var13"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Var3", "Var5", "Var7", "Var9", "Var11", "Var13"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, ["Question1", "Question2A", "Question2B", "Question2C", "Question2D", "Question3", "Question4"], "TreatAsMissing", '');

%% Clear temporary variables

% Load in the data for the two trials, the first is in Data0 and the second
% in Data1 

results1 = fixDir(dir(results1));
results2 = fixDir(dir(results2));

Data1 = []; % Results from the first trial
Data2 = []; % Results from the second trial

for i = 1 : length(results1)
   filename = strcat(results1(i).folder, '/', results1(i).name);
   data = readtable(filename, opts, "UseExcel", false);
   Data1(20*(i-1) + 1:20*(i-1) + 20, 1:7) = table2array(data(trial1map{:,2},:)); 
end

for i = 1 : length(results2)
   filename = strcat(results2(i).folder, '/', results2(i).name);
   data = readtable(filename, opts, "UseExcel", false);
   Data2(20*(i-1) + 1:20*(i-1) + 20, 1:7) = table2array(data(trial2map{:,2},:));  
end

num_patients = 20;
%% Exact Data 
Q1_predicted = -2*ones(60,1);
Q1_real = -2*ones(60,1);
Q2A_predicted = -2*ones(60,1);
Q2A_real = -2*ones(60,1);
Q2B_predicted = -2*ones(60,1);
Q2B_real = -2*ones(60,1);
Q2C_predicted = -2*ones(60,1);
Q2C_real = -2*ones(60,1);
Q2D_predicted = -2*ones(60,1);
Q2D_real = -2*ones(60,1);
Q3_predicted = -2*ones(60,1);
Q3_real = -2*ones(60,1);
Q4_predicted = -2*ones(60,1);
Q4_real = -2*ones(60,1);

mapping = [mapping;mapping;mapping];

for i=1:40 % For each 
    if(mapping{i,2} == 0) %If the real assignment is in the first trial
        %This means that the real results are in first trial, data1, and the predicted is
        %in the second trial, data2.
        Q1_predicted(i) = Data2(i,1);
        Q1_real(i) = Data1(i,1);
        Q2A_predicted(i) = Data2(i,2);
        Q2A_real(i) = Data1(i,2);
        Q2B_predicted(i) = Data2(i,3);
        Q2B_real(i) = Data1(i,3);
        Q2C_predicted(i) = Data2(i,4);
        Q2C_real(i) = Data1(i,4);
        Q2D_predicted(i) = Data2(i,5);
        Q2D_real(i) = Data1(i,5);
        Q3_predicted(i) = Data2(i,6);
        Q3_real(i) = Data1(i,6);
        Q4_predicted(i) = Data2(i,7);
        Q4_real(i) = Data1(i,7);
    else
        Q1_predicted(i) = Data1(i,1);
        Q1_real(i) = Data2(i,1);
        Q2A_predicted(i) = Data1(i,2);
        Q2A_real(i) = Data2(i,2);
        Q2B_predicted(i) = Data1(i,3);
        Q2B_real(i) = Data2(i,3);
        Q2C_predicted(i) = Data1(i,4);
        Q2C_real(i) = Data2(i,4);
        Q2D_predicted(i) = Data1(i,5);
        Q2D_real(i) = Data2(i,5);
        Q3_predicted(i) = Data1(i,6);
        Q3_real(i) = Data2(i,6);
        Q4_predicted(i) = Data1(i,7);
        Q4_real(i) = Data2(i,7);
    end
end 


%% Doctor based responses
d1_q1_real = Q1_real(1:num_patients);
d2_q1_real = Q1_real(num_patients + 1:2*num_patients);
d3_q1_real = Q1_real(2*num_patients + 1:3*num_patients);

d1_q1_pred = Q1_predicted(1:num_patients);
d2_q1_pred = Q1_predicted(num_patients + 1: 2*num_patients);
d3_q1_pred = Q1_predicted(2*num_patients + 1: 3*num_patients);

d1_Q2A_real = Q2A_real(1:num_patients);
d2_Q2A_real = Q2A_real(num_patients + 1: 2*num_patients);
d3_Q2A_real = Q2A_real(2*num_patients + 1: 3*num_patients);

d1_Q2A_pred = Q2A_predicted(1:num_patients);
d2_Q2A_pred = Q2A_predicted(num_patients + 1: 2*num_patients);
d3_Q2A_pred = Q2A_predicted(2*num_patients + 1: 3*num_patients);

d1_Q2B_real = Q2B_real(1:num_patients);
d2_Q2B_real = Q2B_real(num_patients + 1: 2*num_patients);
d3_Q2B_real = Q2B_real(2*num_patients + 1: 3*num_patients);

d1_Q2B_pred = Q2B_predicted(1:num_patients);
d2_Q2B_pred = Q2B_predicted(num_patients + 1: 2*num_patients);
d3_Q2B_pred = Q2B_predicted(2*num_patients + 1: 3*num_patients);

d1_Q2C_real = Q2C_real(1:num_patients);
d2_Q2C_real = Q2C_real(num_patients + 1: 2*num_patients);
d3_Q2C_real = Q2C_real(2*num_patients + 1: 3*num_patients);

d1_Q2C_pred = Q2C_predicted(1:num_patients);
d2_Q2C_pred = Q2C_predicted(num_patients + 1: 2*num_patients);
d3_Q2C_pred = Q2C_predicted(2*num_patients + 1: 3*num_patients);

d1_Q2D_real = Q2D_real(1:num_patients);
d2_Q2D_real = Q2D_real(num_patients + 1: 2*num_patients);
d3_Q2D_real = Q2D_real(2*num_patients + 1: 3*num_patients);

d1_Q2D_pred = Q2D_predicted(1:num_patients);
d2_Q2D_pred = Q2D_predicted(num_patients + 1: 2*num_patients);
d3_Q2D_pred = Q2D_predicted(2*num_patients + 1: 3*num_patients);

d1_q3_real = Q3_real(1:num_patients);
d2_q3_real = Q3_real(num_patients + 1: 2*num_patients);
d3_q3_real = Q3_real(2*num_patients + 1: 3*num_patients);

d1_q3_pred = Q3_predicted(1:num_patients);
d2_q3_pred = Q3_predicted(num_patients + 1: 2*num_patients);
d3_q3_pred = Q3_predicted(2*num_patients + 1: 3*num_patients);

d1_q4_real = Q4_real(1:num_patients);
d2_q4_real = Q4_real(num_patients + 1: 2*num_patients);
d3_q4_real = Q4_real(2*num_patients + 1: 3*num_patients);

d1_q4_pred = Q4_predicted(1:num_patients);
d2_q4_pred = Q4_predicted(num_patients + 1: 2*num_patients);
d3_q4_pred = Q4_predicted(2*num_patients + 1: 3*num_patients);



%% Write data to csv file
GeneralResults = table(Q1_real, Q1_predicted, Q2A_real, Q2A_predicted, Q2B_real, Q2B_predicted, Q2C_real, Q2C_predicted, Q2D_real, Q2D_predicted, Q3_real, Q3_predicted, Q4_real, Q4_predicted);
DoctorResults = table(d1_q1_real, d1_q1_pred, d1_Q2A_real, d1_Q2A_pred, d1_Q2B_real, d1_Q2B_pred, d1_Q2C_real, d1_Q2C_pred, d1_Q2D_real, d1_Q2D_pred, d1_q3_real, d1_q3_pred, d1_q4_real, d1_q4_pred, d2_q1_real, d2_q1_pred, d2_Q2A_real, d2_Q2A_pred, d2_Q2B_real, d2_Q2B_pred, d2_Q2C_real, d2_Q2C_pred, d2_Q2D_real, d2_Q2D_pred, d2_q3_real, d2_q3_pred, d2_q4_real, d2_q4_pred, d3_q1_real, d3_q1_pred, d3_Q2A_real, d3_Q2A_pred, d3_Q2B_real, d3_Q2B_pred, d3_Q2C_real, d3_Q2C_pred, d3_Q2D_real, d3_Q2D_pred, d3_q3_real, d3_q3_pred, d3_q4_real, d3_q4_pred);

writetable(GeneralResults, 'GeneralResults.csv')
writetable(DoctorResults, 'DoctorResults.csv')

