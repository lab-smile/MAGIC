%%
%Description:
%   Extracts all the data from questionaires into a Cell called Data
%
%
% Written by : Simon Kato
%              Smile-LAB @UF


%% Edit paths, p_deidenty is the path to the utilities folder

results_path = './results/';

current_directory = pwd();
cd("../utilities")
utilities = pwd();
cd(current_directory)

p_deident = genpath(utilities);
addpath(p_deident);

%% Do not edit below this point
addpath(p_deident);

results = dir(results_path);
results = fixDir(results);

real_opts = spreadsheetImportOptions;
real_opts.DataRange = 'B2:B63';
real_mapping = readcell('mapping.xlsx', real_opts);

predicted_opts = spreadsheetImportOptions;
predicted_opts.DataRange = 'C2:C63';
predicted_mapping = readcell('mapping.xlsx', predicted_opts);

opts = spreadsheetImportOptions;
opts.VariableNames = {'Question 1', 'Question 2', 'Question 3', 'Question 4'};
opts.VariableTypes = {'int8', 'int8', 'int8', 'int8'};
opts.DataRange = 'C2:F125';

Data = {};

%% Parsing Data
for i = 1 : length(results)
   filename = strcat(results(i).folder, '/', results(i).name);
   data = readcell(filename, opts);
   Data = [Data; data];
end

Q1_predicted = zeros(62*length(results),1);Q1_real = zeros(62*length(results),1);
Q2_predicted = zeros(62*length(results),1);Q2_real = zeros(62*length(results),1);
Q3_predicted = zeros(62*length(results),1);Q3_real = zeros(62*length(results),1);
Q4_predicted = zeros(62*length(results),1);Q4_real = zeros(62*length(results),1);

predicted_map = predicted_mapping;
real_map = real_mapping;

for i = 1:length(results)-1 
   predicted_map = [predicted_map; predicted_mapping]; 
   real_map = [real_map; real_mapping];
end

for i = 1:62*length(results)
    Q1_predicted(i) = Data{2*i - 1 + predicted_map{i,1}, 1};
    Q1_real(i) = Data{2*i - 1 + real_map{i,1}, 1};
    Q2_predicted(i) = Data{2*i - 1 + predicted_map{i,1}, 2};
    Q2_real(i) = Data{2*i - 1 + real_map{i,1}, 2};
    Q3_predicted(i) = Data{2*i - 1 + predicted_map{i,1}, 3};
    Q3_real(i) = Data{2*i - 1 + real_map{i,1}, 3};
    Q4_predicted(i) = Data{2*i - 1 + predicted_map{i,1}, 4};
    Q4_real(i) = Data{2*i - 1 + real_map{i,1},4};
end



%% Constructing Graphs

cmatrix = confusionmat(Q3_real, Q3_predicted);
%confusionchart(cmatrix)

% %% Fleiss Kappa
% d1_q1_real = Q1_real(1:62);
% d2_q1_real = Q1_real(63:124);
% d3_q1_real = Q1_real(125:186);
% 
% q1_fleiss_real_mat = [3*ones(62,1) - sum([d1_q1_real, d2_q1_real, d3_q1_real],2), sum([d1_q1_real, d2_q1_real, d3_q1_real],2)];
% fleiss(q1_fleiss_real_mat)
% 
% d1_q1_pred = Q1_predicted(1:62);
% d2_q1_pred = Q1_predicted(63:124);
% d3_q1_pred = Q1_predicted(125:186);
% 
% q1_fleiss_pred_mat = [3*ones(62,1) - sum([d1_q1_pred, d2_q1_pred, d3_q1_pred],2), sum([d1_q1_pred, d2_q1_pred, d3_q1_pred],2)];
% fleiss(q1_fleiss_pred_mat)
% 
% d1_q2_real = Q2_real(1:62);
% d2_q2_real = Q2_real(63:124);
% d3_q2_real = Q2_real(125:186);
% 
% q2_fleiss_real_mat = [sum([d1_q2_real == 1, d2_q2_real == 1, d3_q2_real == 1],2), sum([d1_q2_real == 2, d2_q2_real == 2, d3_q2_real == 2],2), sum([d1_q2_real == 3, d2_q2_real == 3, d3_q2_real == 3],2), sum([d1_q2_real == 4, d2_q2_real == 4, d3_q2_real == 4],2), sum([d1_q2_real == 5, d2_q2_real == 5, d3_q2_real == 5],2)];
% fleiss(q2_fleiss_real_mat) % Delete row 52
% 
% d1_q2_pred = Q2_predicted(1:62);
% d2_q2_pred = Q2_predicted(63:124);
% d3_q2_pred = Q2_predicted(125:186);
% 
% q2_fleiss_pred_mat = [sum([d1_q2_pred == 1, d2_q2_pred == 1, d3_q2_pred == 1],2), sum([d1_q2_pred == 2, d2_q2_pred == 2, d3_q2_pred == 2],2), sum([d1_q2_pred == 3, d2_q2_pred == 3, d3_q2_pred == 3],2), sum([d1_q2_pred == 4, d2_q2_pred == 4, d3_q2_pred == 4],2), sum([d1_q2_pred == 5, d2_q2_pred == 5, d3_q2_pred == 5],2)];
% fleiss(q2_fleiss_pred_mat) % Delete row 21
% 
% d1_q3_real = Q3_real(1:62);
% d2_q3_real = Q3_real(63:124);
% d3_q3_real = Q3_real(125:186);
% 
% q3_fleiss_real_mat = [sum([d1_q3_real == 1, d2_q3_real == 1, d3_q3_real == 1],2), sum([d1_q3_real == 2, d2_q3_real == 2, d3_q3_real == 2],2), sum([d1_q3_real == 3, d2_q3_real == 3, d3_q3_real == 3],2), sum([d1_q3_real == 4, d2_q3_real == 4, d3_q3_real == 4],2)];
% fleiss(q3_fleiss_real_mat) % Delete row 32
% 
% d1_q3_pred = Q3_predicted(1:62);
% d2_q3_pred = Q3_predicted(63:124);
% d3_q3_pred = Q3_predicted(125:186);
% 
% q3_fleiss_pred_mat = [sum([d1_q3_pred == 1, d2_q3_pred == 1, d3_q3_pred == 1],2), sum([d1_q3_pred == 2, d2_q3_pred == 2, d3_q3_pred == 2],2), sum([d1_q3_pred == 3, d2_q3_pred == 3, d3_q3_pred == 3],2), sum([d1_q3_pred == 4, d2_q3_pred == 4, d3_q3_pred == 4],2)];
% fleiss(q3_fleiss_pred_mat) % Delete row 47
% 
% d1_q4_real = Q4_real(1:62);
% d2_q4_real = Q4_real(63:124);
% d3_q4_real = Q4_real(125:186);
% 
% q4_fleiss_real_mat = [sum([d1_q4_real == 1, d2_q4_real == 1, d3_q4_real == 1],2), sum([d1_q4_real == 2, d2_q4_real == 2, d3_q4_real == 2],2), sum([d1_q4_real == 3, d2_q4_real == 3, d3_q4_real == 3],2), sum([d1_q4_real == 4, d2_q4_real == 4, d3_q4_real == 4],2), sum([d1_q4_real == 5, d2_q4_real == 5, d3_q4_real == 5],2)];
% fleiss(q4_fleiss_real_mat)
% 
% d1_q4_pred = Q4_predicted(1:62);
% d2_q4_pred = Q4_predicted(63:124);
% d3_q4_pred = Q4_predicted(125:186);
% 
% q4_fleiss_pred_mat = [sum([d1_q4_pred == 1, d2_q4_pred == 1, d3_q4_pred == 1],2), sum([d1_q4_pred == 2, d2_q4_pred == 2, d3_q4_pred == 2],2), sum([d1_q4_pred == 3, d2_q4_pred == 3, d3_q4_pred == 3],2), sum([d1_q4_pred == 4, d2_q4_pred == 4, d3_q4_pred == 4],2), sum([d1_q4_pred == 5, d2_q4_pred == 5, d3_q4_pred == 5],2)];
% fleiss(q4_fleiss_pred_mat) % Delete row 21
% 
% fleiss_kappas = [-0.19578; - 0.23647; -0.18279; -0.18007; 0.28365; 0.20987; -0.10509; -0.10448];

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
