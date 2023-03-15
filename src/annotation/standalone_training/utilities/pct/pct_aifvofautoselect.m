function [aif_x,aif_y,vof_x,vof_y,isGood] = pct_aifvofautoselect(data,mask,roi_aif,roi_vof,subj_id,fwindow)
%% PCT_AIFVIFAUTOSELECT finds the AIF/VOF in CTP data automatically
% This function finds the optimal AIF and VOF within an ROI designated by
% the user. The optimal AIF or VOF is the one with the highest peak value
% on the attenuation curve. The default AIF ROI is the top half of the
% image. The default VOF ROI is the bottom half of the image. Set the ROI
% to narrow the search area.
% 
%   Kyle See 3/3/23
%   Smart Medical Informatics Learning and Evaluation (SMILE)
%   Biomedical Engineering
%
%   Input:
%       data     - CTP input data [T x Y x X]
%       mask     - Brain mask [Logical map (Y x X)]
%       roi_aif  - Region of interest for AIF selection [4x1 vector (X1, Y1 ,X2 ,Y2)]
%       roi_vof  - Region of interest for VOF selection [4x1 vector (X1, Y1 ,X2 ,Y2)]
%       subj_id  - Subject's ID. Used for titles and naming. [String]
%
%   Output:
%       AIF_X    - Column coordinate of AIF [Scalar]
%       AIF_Y    - Row coordinate of AIF [Scalar]
%       VOF_X    - Column coordinate of VOF [Scalar]
%       VOF_Y    - Row coordinate of VOF [Scalar]
%       isGood   - Yes or no to keep the automatic selection [String]
%
% ------------------------------------------------------------------------
% Changes
% 3/3/23
%   - Updated the description

close all;

% If no mask input, mask is whole image
if nargin < 2
    mask = ones(size(data,2),size(data,3)); % Grab image size [T x Y x X]
end

% If no AIF ROF, ROI is the top half of the image.
if nargin < 3
    roi_aif = [1,1,size(data,2),size(data,3)/2];
%              X1, Y1, X2, Y2
end

% If no VOF ROI input, ROI is the bottom half of the image.
if nargin < 4
    roi_vof = [1,size(data,3)/2,size(data,2),size(data,3)];
%              X1, Y1, X2, Y2
end

% Obtain an ROI-sized mask
roi_aif_mask = mask(roi_aif(2):roi_aif(4),roi_aif(1):roi_aif(3));
roi_vof_mask = mask(roi_vof(2):roi_vof(4),roi_vof(1):roi_vof(3));

T_cutoff = 60; % consider only T_cutoff time frames due to recirculation

%Get size of CTP data
[time,height,width] = size(data);
T = min(T_cutoff,time);

% Apply brain mask to all layers.
for k = 1:time
    data(k,:,:) = squeeze(data(k,:,:)).*mask;
end

%Extract the middle frame in the time series
I = squeeze(data(round(time/2),:,:));  % <---

%All candidate attenuation curves within radius r of the pivot point
curves_aif = data(1:T,roi_aif(2):roi_aif(4),roi_aif(1):roi_aif(3)); %   <--- Grabbing curves from ALL pixels
curves_vof = data(1:T,roi_vof(2):roi_vof(4),roi_vof(1):roi_vof(3));

%Find the peaks of all attenuation curves
[peaks_aif,tmax_aif] = max(curves_aif,[],1);
[peaks_vof,tmax_vof] = max(curves_vof,[],1);
peaks_aif = squeeze(peaks_aif);
peaks_vof = squeeze(peaks_vof);
tmax_aif = squeeze(tmax_aif);
tmax_vof = squeeze(tmax_vof);   % <--- Time it takes to reach the peak (1-21)

% Mask is applied, but not the threshold yet
mask_peaks_aif = peaks_aif(roi_aif_mask);                           % Apply the mask to the peaks
mask_peaks_vof = peaks_vof(roi_vof_mask);
mask_combined_aif = [mask_peaks_aif,find(roi_aif_mask)];            % Combine the peaks and the index
mask_combined_vof = [mask_peaks_vof,find(roi_vof_mask)];
mask_combined_sorted_aif = sortrows(mask_combined_aif,1,'descend'); % Sort peaks in descending order
mask_combined_sorted_vof = sortrows(mask_combined_vof,1,'descend');

% Get coordinates from indices
[y_coord_aif, x_coord_aif] = ind2sub([(roi_aif(4)-roi_aif(2))+1,(roi_aif(3)-roi_aif(1))+1],mask_combined_sorted_aif(1,2)); % <--- change (1,~) for diff top sorted
[y_coord_vof, x_coord_vof] = ind2sub([(roi_vof(4)-roi_vof(2))+1,(roi_vof(3)-roi_vof(1))+1],mask_combined_sorted_vof(1,2));
%  rows         column

% Correct coordinates to ROI
y_coord_aif = y_coord_aif + (roi_aif(2)-1);
x_coord_aif = x_coord_aif + (roi_aif(1)-1);
y_coord_vof = y_coord_vof + (roi_vof(2)-1);
x_coord_vof = x_coord_vof + (roi_vof(1)-1);

% Plot the AIF/VOF curves
figure(5);
subplot(1,2,2);
% [ left bottom width height ]
if strcmp(fwindow,'local')
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.3 0.25 0.4 0.4]); % Set figure window size (Local)
elseif strcmp(fwindow,'hpg')
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.30 -0.1 1.0 0.8]);  % Set figure window size (HPG)
end
hold on;
set(gca, 'Position', [0.55, 0.15, 0.4, 0.75]);                   % Set position in figure window
plot(data(:,y_coord_aif(1),x_coord_aif(1)),'r','LineWidth',2)    % Plot AIF curve
plot(data(:,y_coord_vof(1),x_coord_vof(1)),'b','LineWidth',2)    % Plot VOF curve
set(gca,'FontSize', 12)
legend('AIF','VOF','Position',[0.6 0.84 0 0],'FontSize', 12)
ylabel('HU','FontSize', 15)
xlabel('Time','FontSize', 15)
xlim([0 21])
ylim([-20 max([data(:,y_coord_aif(1),x_coord_aif(1));data(:,y_coord_vof(1),x_coord_vof(1))])+50])
new_subj_id = [extractBefore(subj_id,'_'),'\_',extractAfter(subj_id,'_')];
curve_name = [new_subj_id,' AIF/VOF Time-Conc. Curve'];
title(curve_name,'FontSize', 16)

% Plot dots on CTP 
figure(5);
subplot(1,2,1);
hold on;
set(gca, 'Position', [-0.15, 0, 0.9, 0.9]);
imshow(I,[0 50]); % <--- Cutout negative values, show middle timepoint in selected slice
plot(x_coord_aif(1),y_coord_aif(1),'r.','MarkerSize',30);
plot(x_coord_vof(1),y_coord_vof(1),'b.','MarkerSize',30);
rectangle('Position',[roi_aif(1),roi_aif(2),roi_aif(3)-roi_aif(1),roi_aif(4)-roi_aif(2)],'LineWidth',1,'EdgeColor','r');
rectangle('Position',[roi_vof(1),roi_vof(2),roi_vof(3)-roi_vof(1),roi_vof(4)-roi_vof(2)],'LineWidth',1,'EdgeColor','b');
xlm=xlim;
new_subj_id = [extractBefore(subj_id,'_'),'\_',extractAfter(subj_id,'_')];
curve_name2 = [new_subj_id,' Most likely AIF/VOF location'];
title(curve_name2,'Position',[mean(xlm)-40 xlm(1)], 'FontSize', 16)

% Prompt the user if they want to save the files
isGood = questdlg('Would you like to keep the automatic selection?','Verify automatic selection','Yes','No','No');

aif_x = y_coord_aif(1);
aif_y = x_coord_aif(1);
vof_x = y_coord_vof(1);
vof_y = x_coord_vof(1);

end