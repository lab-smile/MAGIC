function [VOF,vof_x,vof_y] = pct_vofsearch(data,r,aif_x,aif_y,fwindow,range,text)
%PCT_AIFSEARCH finds the arterial input function from CTP data
%
%   Ruogu Fang Revised 08/22/2013
%   Advanced Multimedia Processing (AMP) Lab, Cornell University
%
%   USAGE:  VOF = PCT_VOFSEARCH(DATA,R);
%
%   PRE:
%       data    - CTP input data [T x Y x X]
%       r       - Radius for AIF or VOF searching around pivot point [Scalar]
%       aif_x   - Column coordinate of AIF [Scalar]
%       aif_y   - Row coordinate of AIF [Scalar]
%       range   - display range [lo hi] (optional)
%       text    - text displayed in the graphical window [String] (optional)
%
%   POST:
%       VOF     - Arterial input function [T x 1]
%       VOF_X   - Column coordinate of VOF [Scalar]
%       VOF_Y   - Row coordinate of VOF [Scalar]
%
% PCT_VOF finds the optimal AIF or VOF within the searching radius r of
% pivot point designated by the user. The optimal AIF or VOF is the one
% with the highest peak value on the attenuation curve.
%
% ------------------------------------------------------------------------
% Changes
% 3/9/23
%   - (Kyle See) Added previous AIF coords as inputs 3-4. Range and text
%   args pushed to inputs 5-6

close all;

if nargin < 6
    range = [0 50];
end

if nargin < 7
    text = 'Please select the VEIN';
end

%Get size of CTP data
[time,height,width] = size(data);

%Extract the middle frame in the time series
I = squeeze(data(round(time/2),:,:));

%Get pivot point for VOF searching
figure;imshow(I,range); title(text,'FontSize',16);
% [ left bottom width height ]
if strcmp(fwindow,'local')
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.3 0.25 0.4 0.6]); % Set figure window size (Local)
elseif strcmp(fwindow,'hpg')
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.30 -0.1 1.0 0.8]);  % Set figure window size (HPG)
end
[px,py] = ginput(1);
px = round(px);
py = round(py);

% Draw white rectangle on the searching area
hold on;
rectangle('Position',[px-r,py-r,2*r,2*r],'LineWidth',3,'EdgeColor','r');

%All candidate attenuation curves within radius r of the pivot point
curves = data(:,py-r:py+r,px-r:px+r);

%Find the peaks of attenuation curves
peaks = squeeze(max(curves,[],1));

%Find the optimal VOF index with the highest peak
[maxPeak,vofIndex] = max(peaks(:));

%Convert index to subscripts
[vof_y, vof_x] = ind2sub(size(peaks),vofIndex);

%Find the optimal VOF
VOF = curves(:,vof_y,vof_x);
AIF = data(:,aif_y,aif_x);

%Show the result curve
figure;
subplot(1,2,2);
if strcmp(fwindow,'local')
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.3 0.25 0.4 0.6]); % Set figure window size (Local)
elseif strcmp(fwindow,'hpg')
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.30 -0.1 1.0 0.8]);  % Set figure window size (HPG)
end
hold on;
set(gca, 'Position', [0.55, 0.15, 0.4, 0.75]);                   % Set position in figure window
plot(AIF,'r','LineWidth',2)    % Plot AIF curve
plot(VOF,'b','LineWidth',2)    % Plot AIF curve
set(gca,'FontSize', 12)
ylabel('HU','FontSize', 15)
xlabel('Time','FontSize', 15)
xlim([0 21])
ylim([-20 max([AIF;VOF])+50])
title('AIF/VOF Time-Conc. Curve','FontSize', 16)

% Show the selection
subplot(1,2,1);
hold on;
set(gca, 'Position', [-0.15, 0, 0.9, 0.9]);
imshow(I,[0 50]); % <--- Cutout negative values, show middle timepoint in selected slice
plot(aif_x,aif_y,'r.','MarkerSize',30);
rectangle('Position',[px-r,py-r,2*r,2*r],'LineWidth',3,'EdgeColor','b');
xlm=xlim;
title('AIF/VOF Selection','Position',[mean(xlm)-40 xlm(1)], 'FontSize', 16)

% figure;
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.25 0.25 0.3 0.4]); % Set figure window size and position
% hold on;
% set(gca, 'Position', [0.24 0.15, 0.6, 0.75])
% plot(AIF,'r','LineWidth',2)
% plot(VOF,'b','LineWidth',2); % Plot AIF curve
% set(gca,'FontSize', 12)
% legend('AIF','VOF','Position',[0.32 0.84 0 0],'FontSize', 12)
% ylabel('HU','FontSize',15)
% xlabel('Time','FontSize',15)
% xlim([0 21])
% ylim([-20 max([AIF;VOF])+50])
% title('AIF/VOF Time-Conc. Curve','FontSize', 16)

%Ask user if the curve is good to continue the computation
choice = questdlg('Would you like to continue with this curve?',...
    'CTP Deconvolution');
% Handle response
switch choice
    case 'Yes'
        close all;
    case 'No'
        close;
        clf;
        VOF = pct_vofsearch(data,r,aif_x,aif_y,range);
    case 'Cancel'
        close all;
end

vof_x = vof_x + px - r - 1;
vof_y = vof_y + py - r - 1;

end


