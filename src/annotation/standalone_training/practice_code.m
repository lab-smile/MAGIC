%% CT Semi-Automatic Annotation Code v1
% The current use of the code is to allow semi-automatic annotation of AIF
% and VOF in temporal CT perfusion volumes. Adapted from Yao Xiao's script
% "gen_PMs_ori_demo.m" from Ruogu Fang's pct toolbox, This script
% automatically annotates given data following subject IDs and only reads
% nifti data. The user is given the choice to manually override the
% automatic annotation if the annotation is not sufficient. Multiple manual
% annotations can be made until an AIF/VOF is chosen.
%
%   Requires: Signal and Image Processing Toolbox
%
%   Kyle See 02/28/23
%   Smart Medical Informatics Learning and Evaluation (SMILE)
%   Biomedical Engineering
%
%---------------------------------------------

close all; clear; clc;

%% Settings
% ===========================
% CHANGE EACH TIME
% ===========================

% NEEDS TO BE CHANGED EACH TIME
% Patient ID (Set it to the folder id the data was found in)
PatientID = '10029901';

% ===========================
% CHANGE ONCE (or if needed)
% ===========================

% Initials to track who made the annotation
initials = 'CHANGEME';

% Subject folder
folder_extr = './ct_extracted';
folder_anno = './ct_annotated';

% Select your slice
slice = 165;   % General slice for the ACA target
% slice = 123; % General slice for the A2 target

% Figure window sizes
fwindow = 'hpg';

% ===========================
% ===========================

%% Code

% Size of temporal data is 512x512x320x21 - X,Y,Z,T

% Initials check
if strcmp(initials,'CHANGEME')
    msgbox('Please change initials')
    return
end

% Grab full ID
dir_anno = dir(folder_anno); % Grab directory path 
for a = 1:length(dir_anno) % Loop through each 
    if dir_anno(a).isdir % Check if directory is a directory
        if contains(dir_anno(a).name, PatientID)
            PatientID = dir_anno(a).name; % Replace shortened ID with full ID
            break
        end
    end
end

% Check for existing directory, prompt to remove or just replace it.
check_auto = fullfile(folder_anno,PatientID,[PatientID,'_',initials,'_automatic.png']);
check_manu = fullfile(folder_anno,PatientID,[PatientID,'_',initials,'_manual.png']);
if exist(check_auto,'file') || exist(check_manu,'file')
    response = questdlg('Existing file detected. Choose how to proceed.','File Detected.','Overwrite','Delete','Skip','Overwrite');
else
    response = 'Overwrite';
end

if strcmp(response,'Overwrite')

    % Remove existing files
    delete(fullfile(folder_anno,PatientID,'*'))
    
    % Set paths. Expecting relative paths.
    CTPToolbox = './utilities/pct';  % https://github.com/ruogufang/pct
    addpath(genpath(CTPToolbox));    % Set CTP path

    % Find temporal data. As nifti file and largest size (series 3)
    niftiDir = dir(fullfile(folder_extr,PatientID));        % Grab directory
    idx = find([niftiDir.bytes] == max([niftiDir.bytes]));  % Find position of largest file
    Volume = niftiDir(idx).name;                            % Set volume name using position

    % Code expects a .mat file, but we load with nifti instead
    volume = niftiread(fullfile(folder_extr,PatientID,Volume)); % Read the nifti file
    ctp_vol = rot90(squeeze(volume(:,:,slice,:)));              % Rotate volume 90 degrees and slice
    [Y, X, T] = size(ctp_vol);                                  % Grab size of data

    % Plot the non-enhanced perfusion slice
    % figure; imshow(ctp_vol(:,:,11),[0 160]);
    % title('CTP slice');

    %this code may change depending on your unique data input. fit the double
    %and T x Y x X format.
    data = squeeze(ctp_vol);%V to data
    data = permute(data,[3 1 2]); % to T Y X
    % data = squeeze(V);
    data = double(data);

    % PCT Parameters: some parameters may change depending on patient and
    % unique scan characteristics. only change if you know what you are doing.
    kappa = 0.73;  % Hematocrit correction factor
    loth = 0;      % Lower segmentation threshold
    hith = 120;    % Upper segmentation threshold
    rho = 1.05;    % Average brain tissue density
    fsize = 10;    % Size of Gaussian filter - original 5, spatial smoothing
    PRE_bbbp = 1;  % First frame in BBBP calculation
    POST_bbbp = T; % Last frame in BBBP calculation
    sigma = 20;    % Standard deviation of added Gaussian noise to CT data
    dt = 0.5;      % Time step in time series
    ftsize = 3;    % Size of temporal gaussian filter.
    PRE = 1;
    POST = T;

    % SVD parameters
    lambda = 0.15;  %Truncation parameter
    m = 3;          %Extend the data matrix m time for block circulant

    % Process CTP slice
    B = squeeze(mean(data(1:3,:,:),1));
    mask = pct_brainMask(B,0,120,15);           % Compute brain mask (Req. signal and img toolbox)
    data = pct_filter(data, fsize);             % Spatial filtering
    data = pct_gaussfilter(data,ftsize);        % Time filering
    data = pct_segment(data, loth, hith, PRE);  % Segmentation
    data = pct_contconv(data, PRE);             % Subtract base image
    data = pct_hematocrit(data, kappa);         % Correct for hematocrit differences
        
    % Manual Selection
    [AIFx,AIFy,VOFx,VOFy] = pct_aifvofmanualselect(data,mask,PatientID,fwindow);
        
    saveas(gcf,fullfile(folder_anno,PatientID,[PatientID,'_',initials,'_manual.png'])) % For 2019b

    % Print AIF and VOF coordinates
    fprintf("Unique ID: %s\n",PatientID)
    fprintf("( Highlight the numbers and copy to Google Sheets )\n")
    fprintf(" X    Y    Z    X    Y    Z\n")
    fprintf("%d, %d, %d, %d, %d, %d\n",AIFx, AIFy, slice, VOFx, VOFy, slice)
    fprintf('--------- done --------\n');

elseif strcmp(response,'Delete')
    delete(fullfile(folder_anno,PatientID,'*'))
    fprintf("File deleted and skipping the annotation.\n")
    fprintf('--------- done --------\n');
    
else
    fprintf("Skipping the annotation.\n")
    fprintf('--------- done --------\n');
end