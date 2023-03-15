function [AIF,aif_x,aif_y] = pct_aifsearch(data,r,fwindow,range,text)
%PCT_AIFSEARCH finds the arterial input function from CTP data
%
%   Ruogu Fang Revised 08/22/2013
%   Advanced Multimedia Processing (AMP) Lab, Cornell University
%
%   USAGE:  AIF = PCT_AIFSEARCH(DATA,R);
%
%   PRE:
%       data    - CTP input data [T x Y x X]
%       r       - Radius for AIF or VOF searching around pivot point [Scalar]
%       range   - display range [lo hi] (optional)
%       text    - text displayed in the graphical window [String] (optional)
%
%   POST:
%       AIF     - Arterial input function [T x 1]
%       AIF_X   - Column coordinate of AIF [Scalar]
%       AIF_Y   - Row coordinate of AIF [Scalar]
%
% PCT_AIF finds the optimal AIF or VOF within the searching radius r of
% pivot point designated by the user. The optimal AIF or VOF is the one
% with the highest peak value on the attenuation curve.
%
% ------------------------------------------------------------------------
% Changes
% 3/9/23
%   - (Kyle See) Updated graph look

close all;

if nargin < 4
    range = [0 50];
end

if nargin < 5
    text = 'Please select the ARTERY';
end

%Get size of CTP data
[time,height,width] = size(data);

%Extract the middle frame in the time series
I = squeeze(data(round(time/2),:,:));

%Get pivot point for AIF searching
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

%Find the optimal AIF index with the highest peak
[maxPeak,aifIndex] = max(peaks(:));

%Convert index to subscripts
[aif_y, aif_x] = ind2sub(size(peaks),aifIndex);

%Find the optimal AIF
AIF = curves(:,aif_y,aif_x);

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
set(gca,'FontSize', 12)
ylabel('HU','FontSize', 15)
xlabel('Time','FontSize', 15)
xlim([0 21])
ylim([-20 max(AIF)+50])
title('AIF Time-Conc. Curve','FontSize', 16)

% Show the selection alongside
subplot(1,2,1);
hold on;
set(gca, 'Position', [-0.15, 0, 0.9, 0.9]);
imshow(I,[0 50]); % <--- Cutout negative values, show middle timepoint in selected slice
rectangle('Position',[px-r,py-r,2*r,2*r],'LineWidth',3,'EdgeColor','r');
xlm=xlim;
title('AIF Selection','Position',[mean(xlm)-40 xlm(1)], 'FontSize', 16)

% figure;
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.25 0.25 0.3 0.4]); % Set figure window size and position
% hold on;
% set(gca, 'Position', [0.24 0.15, 0.6, 0.75])
% plot(AIF,'r','LineWidth',2); % Plot AIF curve
% set(gca,'FontSize', 12)
% ylabel('HU','FontSize',15)
% xlabel('Time','FontSize',15)
% xlim([0 21])
% ylim([-20 max(AIF)+50])
% title('AIF Time-Conc. Curve','FontSize', 16)

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
        AIF = pct_aifsearch(data,r,range);
    case 'Cancel'
        close all;
end

aif_x = aif_x + px - r - 1;
aif_y = aif_y + py - r - 1;

end


