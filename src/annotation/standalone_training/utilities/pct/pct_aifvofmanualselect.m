function [AIFx,AIFy,VOFx,VOFy] = pct_aifvofmanualselect(data,mask,subj_id,fwindow)
% PCT_AIFVOFMANUALSELECT finds the AIF/VOF in CTP data manually
% This function finds the optimal AIF within the searching radius r of
% pivot point designated by the user. The optimal AIF or VOF is the one
% with the highest peak value on the attenuation curve.
% 
%   Kyle See 3/10/23
%   Smart Medical Informatics Learning and Evaluation (SMILE)
%   Biomedical Engineering
% 
%   Input:
%       data     - CTP input data [T x Y x X]
%       mask     - Brain mask [Logical map (Y x X)]
%       subj_id  - Subject's ID. Used for titles and naming. [String]
%
%   Output:
%       AIF_X    - Column coordinate of AIF [Scalar]
%       AIF_Y    - Row coordinate of AIF [Scalar]
%       VOF_X    - Column coordinate of VOF [Scalar]
%       VOF_Y    - Row coordinate of VOF [Scalar]
% 
% ------------------------------------------------------------------------

close all;

% Manual selection
[AIF_manual,AIFx,AIFy]=pct_aifsearch(data,5,fwindow);
[VOF_manual,VOFx,VOFy]=pct_vofsearch(data,5,AIFx,AIFy,fwindow);

%Get size of CTP data
[time,height,width] = size(data);

% Apply brain mask to all layers.
for k = 1:time
    data(k,:,:) = squeeze(data(k,:,:)).*mask;
end

%Extract the middle frame in the time series
I = squeeze(data(round(time/2),:,:));

% Plot the AIF/VOF curves
figure(6); % Random figure number call to avoid overlap
subplot(1,2,2);
% [ left bottom width height ]
if strcmp(fwindow,'local')
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.3 0.25 0.4 0.6]); % Set figure window size (Local)
elseif strcmp(fwindow,'hpg')
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.30 -0.1 1.0 0.8]);  % Set figure window size (HPG)
end
hold on;
set(gca, 'Position', [0.55, 0.15, 0.4, 0.75]);                   % Set position in figure window
plot(data(:,AIFy,AIFx),'r','LineWidth',2)    % Plot AIF curve
plot(data(:,VOFy,VOFx),'b','LineWidth',2)    % Plot VOF curve
set(gca,'FontSize', 12)
legend('AIF','VOF','Position',[0.6 0.84 0 0],'FontSize', 12)
ylabel('HU','FontSize', 15)
xlabel('Time','FontSize', 15)
xlim([0 21])
new_subj_id = [extractBefore(subj_id,'_'),'\_',extractAfter(subj_id,'_')];
curve_name = [new_subj_id,' AIF/VOF Time-Conc. Curve'];
title(curve_name,'FontSize', 16)

% Plot dots on CTP
subplot(1,2,1);
hold on;
set(gca, 'Position', [-0.15, 0, 0.9, 0.9]);
imshow(I,[0 50]); % <--- Cutout negative values, show middle timepoint in selected slice
plot(AIFx,AIFy,'r.','MarkerSize',30);
plot(VOFx,VOFy,'b.','MarkerSize',30);
xlm=xlim;
new_subj_id = [extractBefore(subj_id,'_'),'\_',extractAfter(subj_id,'_')];
curve_name2 = [new_subj_id,' Manual AIF/VOF location'];
title(curve_name2,'Position',[mean(xlm)-40 xlm(1)], 'FontSize', 16)

% One last verification or redo
anotherIsGood = questdlg('Would you like to keep the manual selection? (Selecting No will redo the manual selection)','Verify manual selection','Yes','No','No');
if strcmp(anotherIsGood,'No')
    pct_aifvofmanualselect(data,mask,subj_id,fwindow)
end

end