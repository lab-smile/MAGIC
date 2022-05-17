%%
%Description:
%   Extracts all the data from questionaires into a Cell called Data
%
%
% Written by : Simon Kato
%              Smile-LAB @UF
%% Edit paths, p_deidenty is the path to the utilities folder

results_path = './results';

%% Do not edit below this point
current_directory = pwd();
cd("../utilities")
utilities = pwd();
cd(current_directory)

p_deident = genpath(utilities);
addpath(p_deident);

results = dir(results_path);
results = fixDir(results);

%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 2);

% Specify sheet and range
opts.Sheet = "Sheet1";
opts.DataRange = "A2:B11";

% Specify column names and types
opts.VariableNames = ["all_patients", "permuted_assignments"];
opts.VariableTypes = ["string", "double"];

% Specify variable properties
opts = setvaropts(opts, "all_patients", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "all_patients", "EmptyFieldRule", "auto");

% Import the data
mapping = readtable("C:\Users\skato1\Desktop\REU\scripts\questionaire\permuted_mapping.xlsx", opts, "UseExcel", false);


% Clear temporary variables
clear opts

%% Setup the Import Options and import the data
opts = spreadsheetImportOptions;
opts.VariableNames = {'Question 1', 'Question 2A','Question 2B','Question 2C','Question 2D', 'Question 3','Question 4'};
opts.VariableTypes = {'double', 'double', 'double', 'double', 'double', 'double', 'double'};
opts.DataRange = 'B2:H11';

%% Import Data
OrderedData = [];

for i = 1 : length(results)
   filename = strcat(results(i).folder, '/', results(i).name);
   data = readmatrix(filename, opts);
   OrderedData(10*(i-1) + 1:10*(i-1) + 10, 1:7) = data(mapping{:,2},:); %Fills in by 10 since only 10 ctp, need to change depending on num CTPs
end

num_patients = length(data)/2;
%% Exact Data 
Q1_predicted = OrderedData(2:2:end,1);
Q1_real = OrderedData(1:2:end,1);
Q2A_predicted = OrderedData(2:2:end,2);
Q2A_real = OrderedData(1:2:end,2);
Q2B_predicted = OrderedData(2:2:end,3);
Q2B_real = OrderedData(1:2:end,3);
Q2C_predicted = OrderedData(2:2:end,4);
Q2C_real = OrderedData(1:2:end,4);
Q2D_predicted = OrderedData(2:2:end,5);
Q2D_real = OrderedData(1:2:end,5);
Q3_predicted = OrderedData(2:2:end,6);
Q3_real = OrderedData(1:2:end,6);
Q4_predicted = OrderedData(2:2:end,7);
Q4_real = OrderedData(1:2:end,7);


%% Constructing Graphs
cmatrix = confusionmat(Q3_real, Q3_predicted);
confusionchart(cmatrix)

%% Fleiss Kappa and Doctor based responses
d1_q1_real = Q1_real(1:num_patients);
d2_q1_real = Q1_real(num_patients + 1:2*num_patients);
d3_q1_real = Q1_real(2*num_patients + 1:3*num_patients);

q1_fleiss_real_mat = [3*ones(num_patients,1) - sum([d1_q1_real, d2_q1_real, d3_q1_real],2), sum([d1_q1_real, d2_q1_real, d3_q1_real],2)];
%fleiss(q1_fleiss_real_mat)

d1_q1_pred = Q1_predicted(1:num_patients);
d2_q1_pred = Q1_predicted(num_patients + 1: 2*num_patients);
d3_q1_pred = Q1_predicted(2*num_patients + 1: 3*num_patients);

q1_fleiss_pred_mat = [3*ones(num_patients,1) - sum([d1_q1_pred, d2_q1_pred, d3_q1_pred],2), sum([d1_q1_pred, d2_q1_pred, d3_q1_pred],2)];
%fleiss(q1_fleiss_pred_mat)

d1_Q2A_real = Q2A_real(1:num_patients);
d2_Q2A_real = Q2A_real(num_patients + 1: 2*num_patients);
d3_Q2A_real = Q2A_real(2*num_patients + 1: 3*num_patients);

Q2A_fleiss_real_mat = [sum([d1_Q2A_real == -1, d2_Q2A_real == -1, d3_Q2A_real == -1],2), sum([d1_Q2A_real == 0, d2_Q2A_real == 0, d3_Q2A_real == 0],2), sum([d1_Q2A_real == 1, d2_Q2A_real == 1, d3_Q2A_real == 1],2)];
% fleiss(Q2A_fleiss_real_mat) 

d1_Q2A_pred = Q2A_predicted(1:num_patients);
d2_Q2A_pred = Q2A_predicted(num_patients + 1: 2*num_patients);
d3_Q2A_pred = Q2A_predicted(2*num_patients + 1: 3*num_patients);

Q2A_fleiss_pred_mat = [sum([d1_Q2A_pred == -1, d2_Q2A_pred == -1, d3_Q2A_pred == -1],2), sum([d1_Q2A_pred == 0, d2_Q2A_pred == 0, d3_Q2A_pred == 0],2), sum([d1_Q2A_pred == 1, d2_Q2A_pred == 1, d3_Q2A_pred == 1],2)];
%fleiss(Q2A_fleiss_pred_mat) 

d1_Q2B_real = Q2B_real(1:num_patients);
d2_Q2B_real = Q2B_real(num_patients + 1: 2*num_patients);
d3_Q2B_real = Q2B_real(2*num_patients + 1: 3*num_patients);

Q2B_fleiss_real_mat = [sum([d1_Q2B_real == -1, d2_Q2B_real == -1, d3_Q2B_real == -1],2), sum([d1_Q2B_real == 0, d2_Q2B_real == 0, d3_Q2B_real == 0],2), sum([d1_Q2B_real == 1, d2_Q2B_real == 1, d3_Q2B_real == 1],2)];
%fleiss(Q2B_fleiss_real_mat) 

d1_Q2B_pred = Q2B_predicted(1:num_patients);
d2_Q2B_pred = Q2B_predicted(num_patients + 1: 2*num_patients);
d3_Q2B_pred = Q2B_predicted(2*num_patients + 1: 3*num_patients);

Q2B_fleiss_pred_mat = [sum([d1_Q2B_pred == -1, d2_Q2B_pred == -1, d3_Q2B_pred == -1],2), sum([d1_Q2B_pred == 0, d2_Q2B_pred == 0, d3_Q2B_pred == 0],2), sum([d1_Q2B_pred == 1, d2_Q2B_pred == 1, d3_Q2B_pred == 1],2)];
%fleiss(Q2B_fleiss_pred_mat) 

d1_Q2C_real = Q2C_real(1:num_patients);
d2_Q2C_real = Q2C_real(num_patients + 1: 2*num_patients);
d3_Q2C_real = Q2C_real(2*num_patients + 1: 3*num_patients);

Q2C_fleiss_real_mat = [sum([d1_Q2C_real == -1, d2_Q2C_real == -1, d3_Q2C_real == -1],2), sum([d1_Q2C_real == 0, d2_Q2C_real == 0, d3_Q2C_real == 0],2), sum([d1_Q2C_real == 1, d2_Q2C_real == 1, d3_Q2C_real == 1],2)];
%fleiss(Q2C_fleiss_real_mat) 

d1_Q2C_pred = Q2C_predicted(1:num_patients);
d2_Q2C_pred = Q2C_predicted(num_patients + 1: 2*num_patients);
d3_Q2C_pred = Q2C_predicted(2*num_patients + 1: 3*num_patients);

Q2C_fleiss_pred_mat = [sum([d1_Q2C_pred == -1, d2_Q2C_pred == -1, d3_Q2C_pred == -1],2), sum([d1_Q2C_pred == 0, d2_Q2C_pred == 0, d3_Q2C_pred == 0],2), sum([d1_Q2C_pred == 1, d2_Q2C_pred == 1, d3_Q2C_pred == 1],2)];
%fleiss(Q2C_fleiss_pred_mat) 

d1_Q2D_real = Q2D_real(1:num_patients);
d2_Q2D_real = Q2D_real(num_patients + 1: 2*num_patients);
d3_Q2D_real = Q2D_real(2*num_patients + 1: 3*num_patients);

Q2D_fleiss_real_mat = [sum([d1_Q2D_real == -1, d2_Q2D_real == -1, d3_Q2D_real == -1],2), sum([d1_Q2D_real == 0, d2_Q2D_real == 0, d3_Q2D_real == 0],2), sum([d1_Q2D_real == 1, d2_Q2D_real == 1, d3_Q2D_real == 1],2)];
%fleiss(Q2D_fleiss_real_mat) 

d1_Q2D_pred = Q2D_predicted(1:num_patients);
d2_Q2D_pred = Q2D_predicted(num_patients + 1: 2*num_patients);
d3_Q2D_pred = Q2D_predicted(2*num_patients + 1: 3*num_patients);

Q2D_fleiss_pred_mat = [sum([d1_Q2D_pred == -1, d2_Q2D_pred == -1, d3_Q2D_pred == -1],2), sum([d1_Q2D_pred == 0, d2_Q2D_pred == 0, d3_Q2D_pred == 0],2), sum([d1_Q2D_pred == 1, d2_Q2D_pred == 1, d3_Q2D_pred == 1],2)];
%fleiss(Q2D_fleiss_pred_mat) 

d1_q3_real = Q3_real(1:num_patients);
d2_q3_real = Q3_real(num_patients + 1: 2*num_patients);
d3_q3_real = Q3_real(2*num_patients + 1: 3*num_patients);

q3_fleiss_real_mat = [sum([d1_q3_real == 1, d2_q3_real == 1, d3_q3_real == 1],2), sum([d1_q3_real == 2, d2_q3_real == 2, d3_q3_real == 2],2), sum([d1_q3_real == 3, d2_q3_real == 3, d3_q3_real == 3],2), sum([d1_q3_real == 4, d2_q3_real == 4, d3_q3_real == 4],2)];
%fleiss(q3_fleiss_real_mat) 

d1_q3_pred = Q3_predicted(1:num_patients);
d2_q3_pred = Q3_predicted(num_patients + 1: 2*num_patients);
d3_q3_pred = Q3_predicted(2*num_patients + 1: 3*num_patients);

q3_fleiss_pred_mat = [sum([d1_q3_pred == 1, d2_q3_pred == 1, d3_q3_pred == 1],2), sum([d1_q3_pred == 2, d2_q3_pred == 2, d3_q3_pred == 2],2), sum([d1_q3_pred == 3, d2_q3_pred == 3, d3_q3_pred == 3],2), sum([d1_q3_pred == 4, d2_q3_pred == 4, d3_q3_pred == 4],2)];
%fleiss(q3_fleiss_pred_mat) 

d1_q4_real = Q4_real(1:num_patients);
d2_q4_real = Q4_real(num_patients + 1: 2*num_patients);
d3_q4_real = Q4_real(2*num_patients + 1: 3*num_patients);

q4_fleiss_real_mat = [sum([d1_q4_real == 1, d2_q4_real == 1, d3_q4_real == 1],2), sum([d1_q4_real == 2, d2_q4_real == 2, d3_q4_real == 2],2), sum([d1_q4_real == 3, d2_q4_real == 3, d3_q4_real == 3],2), sum([d1_q4_real == 4, d2_q4_real == 4, d3_q4_real == 4],2), sum([d1_q4_real == 5, d2_q4_real == 5, d3_q4_real == 5],2)];
%fleiss(q4_fleiss_real_mat)

d1_q4_pred = Q4_predicted(1:num_patients);
d2_q4_pred = Q4_predicted(num_patients + 1: 2*num_patients);
d3_q4_pred = Q4_predicted(2*num_patients + 1: 3*num_patients);

q4_fleiss_pred_mat = [sum([d1_q4_pred == 1, d2_q4_pred == 1, d3_q4_pred == 1],2), sum([d1_q4_pred == 2, d2_q4_pred == 2, d3_q4_pred == 2],2), sum([d1_q4_pred == 3, d2_q4_pred == 3, d3_q4_pred == 3],2), sum([d1_q4_pred == 4, d2_q4_pred == 4, d3_q4_pred == 4],2), sum([d1_q4_pred == 5, d2_q4_pred == 5, d3_q4_pred == 5],2)];
%fleiss(q4_fleiss_pred_mat) 

%fleiss_kappas = [-0.19578; - 0.23647; -0.18279; -0.18007; 0.28365; 0.20987; -0.10509; -0.10448];
%% Write data to csv file to plot in R and copy to website
GeneralResults = table(Q1_real, Q1_predicted, Q2A_real, Q2A_predicted, Q2B_real, Q2B_predicted, Q2C_real, Q2C_predicted, Q2D_real, Q2D_predicted, Q3_real, Q3_predicted, Q4_real, Q4_predicted);
DoctorResults = table(d1_q1_real, d1_q1_pred, d1_Q2A_real, d1_Q2A_pred, d1_Q2B_real, d1_Q2B_pred, d1_Q2C_real, d1_Q2C_pred, d1_Q2D_real, d1_Q2D_pred, d1_q3_real, d1_q3_pred, d1_q4_real, d1_q4_pred, d2_q1_real, d2_q1_pred, d2_Q2A_real, d2_Q2A_pred, d2_Q2B_real, d2_Q2B_pred, d2_Q2C_real, d2_Q2C_pred, d2_Q2D_real, d2_Q2D_pred, d2_q3_real, d2_q3_pred, d2_q4_real, d2_q4_pred, d3_q1_real, d3_q1_pred, d3_Q2A_real, d3_Q2A_pred, d3_Q2B_real, d3_Q2B_pred, d3_Q2C_real, d3_Q2C_pred, d3_Q2D_real, d3_Q2D_pred, d3_q3_real, d3_q3_pred, d3_q4_real, d3_q4_pred);

writetable(GeneralResults, 'GeneralResults.csv')
writetable(DoctorResults, 'DoctorResults.csv')

%% Confidence of Answers
confidence_of_incorrect_pred = [];
confidence_of_incorrect_real = [];
confidence_of_correctly_pred = [];
confidence_of_correctly_real = [];

for i = 1:length(Q4_real)
    if (Q3_predicted(i) ~= Q3_real(i))
        confidence_of_incorrect_pred = [confidence_of_incorrect_pred; Q4_predicted(i)];
        confidence_of_incorrect_real = [confidence_of_incorrect_real; Q4_real(i)];
    else
        confidence_of_correctly_pred = [confidence_of_correctly_pred; Q4_predicted(i)];
        confidence_of_correctly_real = [confidence_of_correctly_real; Q4_real(i)];
    end
end

mean(confidence_of_incorrect_pred)
mean(confidence_of_incorrect_real)
