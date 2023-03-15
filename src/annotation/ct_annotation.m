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
% INSTRUCTIONS
% - Set the subject folder
% - Set the patient ID
% - Modify the slice if needed
% - Modify ROI if needed
%
%---------------------------------------------
% Last Updated: 3/15/2023
% 2/28/23
% - Changed .mat loading to .nifti
% - Removed .mat associations for loading
% - Added loading function for specific CT files
% 
% 3/9/23
% - Added a choice to overwrite, delete, or skip the files
% - Added a way to grab the rest of the unique ID. Google Sheets has the
%       shortened ID without year.
% - Added a display of the final results after manual annotation.
% - Added the AIF/VOF coordinates at the bottom of the command window once
%       complete. It is in a format that is easily copied to Google Sheets.
% - Changed the choice of manual or auto annotation to auto annotation
%       followed by optional manual override.
% - Changed the grouping of functions.
% - Removed the perfusion map handling.
% - Removed the display PMA toolbox.
% - Moved the manual AIF/VOF selection into its own function.
% 
% 3/15/23
% - Added figure window option depending on local or HPG
% - Changed the naming scheme to include the annotators initials
% - Changed the title for the manual override to 'Manual location' from
%   'Most likely location'
% - Fixed figure window conflicts using close all in the select functions.
% 
% To-do
% - Design a method to automatically reject bad AIF/VOF using parametric
%   fitting
% - Design a method to identify ventricles (dark CSF regions) to better
%   automatically put the ROI for AIF.
% 

close all; clear; clc;

%% Settings
% ===========================
% CHANGE EACH TIME
% ===========================

% NEEDS TO BE CHANGED EACH TIME
% Patient ID (Set it to the folder id the data was found in)
PatientID = '20011101';

% ===========================
% CHANGE ONCE (or if needed)
% ===========================

% Initials to track who made the annotation
initials = 'KBS';

% Subject folder
folder_extr = '/red/ruogu.fang/kylebsee/MAGIC/ct_extracted';
folder_anno = '/red/ruogu.fang/kylebsee/MAGIC/ct_annotated';

% Select your slice
slice = 210;   % General slice for the ACA target
% slice = 123; % General slice for the A2 target

% Select your AIF/VOF ROIs
% [ X1, Y1, X2, Y2 ]

% AIFs
roi_aif = [199,110,339,220];   % Small box around the ACA target
% roi_aif = [199,203,339,250]; % Tight box for A2 target (change slice too)
% roi_aif = [1,1,512,256];     % Top 50% of image

% VOFs
roi_vof = [199,370,339,468];   % Small box around the SSS target
% roi_vof = [1,256,512,512];   % Bottom 50% of image

% Figure window sizes
fwindow = 'hpg';

% ===========================
% ===========================

%% Code

% Size of temporal data is 512x512x320x21 - X,Y,Z,T

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

    % Remove existing file
    if exist(check_auto,'file'); delete(check_auto); end
    if exist(check_manu,'file'); delete(check_manu); end
    
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

    % Auto-select AIF/VOF
    [AIFy,AIFx,VOFy,VOFx,isGood]=pct_aifvofautoselect(data,mask,roi_aif,roi_vof,PatientID,fwindow);

    % Run manual if auto-select is not good quality
    if strcmp(isGood,'Yes')
        % exportgraphics(gcf,[subj_id,'.png'],'Resolution',300) % For 2022b
        saveas(gcf,fullfile(folder_anno,PatientID,[PatientID,'_',initials,'_automatic.png'])) % For 2019b
    else
        
        [AIFx,AIFy,VOFx,VOFy] = pct_aifvofmanualselect(data,mask,PatientID,fwindow);
        
        % Save image
        saveas(gcf,fullfile(folder_anno,PatientID,[PatientID,'_',initials,'_manual.png'])) % For 2019b
    end

    % Print AIF and VOF coordinates
    fprintf("Unique ID: %s\n",PatientID)
    fprintf("( Highlight the numbers and copy to Google Sheets )\n")
    fprintf(" X    Y    Z    X    Y    Z\n")
    fprintf("%d, %d, %d, %d, %d, %d\n",AIFx, AIFy, slice, VOFx, VOFy, slice)
    fprintf('--------- done --------\n');

elseif strcmp(response,'Delete')
    if exist(check_auto,'file'); delete(check_auto); end
    if exist(check_manu,'file'); delete(check_manu); end
    fprintf("File deleted and skipping the annotation.\n")
    fprintf('--------- done --------\n');
    
else
    fprintf("Skipping the annotation.\n")
    fprintf('--------- done --------\n');
end