clear; clc; close all;

% folders = {'test_results'};


% for k = 1:length(folders)
%     folder_name = cell2mat(folders(k));

load('Rapid_Colormap.mat'); % contains variable Rapid_U
% addpath(genpath('C:/Users/Garrett/Desktop/Display_PMA_Colormaps/'));
% datapath_real = 'C:\Users\Garrett\Desktop\MAGIC\src\sample\test';
% datapath_fake = fullfile(strcat('C:\Users\Garrett\Desktop\MAGIC\DEMO_RESULTS\', folder_name, '\')); %same inputs as metrics
% outpath = fullfile(strcat('C:\Users\Garrett\Desktop\MAGIC\DEMO_RESULTS\', folder_name, '_fakereal_combined_v2\'));

datapath_real = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\real';
datapath_fake = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\fake';
outpath = 'D:\Desktop Files\Dropbox (UFL)\Quick Coding Scripts\Testing MAGIC pipeline\series';

%no mm loss
%groundtruth_200
classA = 'MTT';
classB = 'TTP';
classC = 'CBF';
classD = 'CBV';

%parpool;

datapath_real = fullfile(datapath_real);
datapath_fake = fullfile(datapath_fake);
outpath = fullfile(outpath);
fakepath = fullfile(outpath,'fake');
realpath = fullfile(outpath,'real');
ncctpath = fullfile(outpath,'ncct');

if ~exist(outpath,'dir'), mkdir(outpath); end
if ~exist(fakepath,'dir'), mkdir(fakepath); end
if ~exist(realpath,'dir'), mkdir(realpath); end
if ~exist(ncctpath,'dir'), mkdir(ncctpath); end

fake_files = dir(fullfile(datapath_fake,'*.png'));
real_files = dir(fullfile(datapath_real,'*.png'));
%%
for i = 1:length(fake_files)
    file = fake_files(i);
    filefolder = file.folder; filename = file.name;
    savename = strrep(filename,'_output','');
    dotloc = find(savename=='.');
    if ~isempty(dotloc)
        savename = savename(1:dotloc(1)-1);
    end
    imgpath = fullfile(filefolder, filename);
    img = imread(imgpath);
    unit = size(img, 2) / 4;
    imgA = rgb2gray(img(:,1:unit,:));
    imgB = rgb2gray(img(:,unit+1:unit*2,:));
    imgC = rgb2gray(img(:,unit*2+1:unit*3,:));
    imgD = rgb2gray(img(:,unit*3+1:unit*4,:));
    
    figure;
    
    p1 = subplot(221);
    %[~,cm1,~] = ctshow_pma(imgA,(imgA~=0),[0 255],'pma',Rapid_U);
    imshow(imgA);
    title(classA);
    
    p2 = subplot(222);
    %[~,cm2,~] = ctshow_pma(imgB,(imgB~=0),[0 255],'pma',Rapid_U);
    imshow(imgB);
    title(classB);
    
    p3 = subplot(223);
    %[~,cm3,~] = ctshow_pma(imgC,(imgC~=0),[0 255],'pma',Rapid_U);
    imshow(imgC);
    title(classC);
    
    p4 = subplot(224);
    %[~,cm4,~] = ctshow_pma(imgD,(imgD~=0),[0 255],'pma',Rapid_U);
    imshow(imgD);
    title(classD);
    
    colormap(p1, Rapid_U);
    colormap(p2, Rapid_U);
    colormap(p3, Rapid_U);
    colormap(p4, Rapid_U);
    
    imgtitle = strcat(savename,'_Simulated'); sgtitle(strrep(imgtitle,'_','\_'));
    %f = getframe;
    saveas(gcf,fullfile(fakepath,strcat(imgtitle,'.png')));
    close all;
    fprintf('Done with %s\n',savename);
end

%%
for i = 1:length(real_files)
    file = real_files(i);
    filefolder = file.folder; filename = file.name;
    savename = strrep(filename,'_output','');
    dotloc = find(savename=='.');
    if ~isempty(dotloc)
        savename = savename(1:dotloc(1)-1);
    end
    imgpath = fullfile(filefolder, filename);
    img = imread(imgpath);
    unit = size(img, 2) / 5;
    ncctimg = img(:,1:unit,:); ncctimg = ncctimg(:,:,2);
    
    imgA = rgb2gray(img(:,unit+1:unit*2,:));
    imgB = rgb2gray(img(:,unit*2+1:unit*3,:));
    imgC = rgb2gray(img(:,unit*3+1:unit*4,:));
    imgD = rgb2gray(img(:,unit*4+1:unit*5,:));
    
    figure;
    
    p1 = subplot(221);
    %[~,cm1,~] = ctshow_pma(imgA,(imgA~=0),[0 255],'pma',Rapid_U);
    imshow(imgA);
    title(classA);
    
    p2 = subplot(222);
    %[~,cm2,~] = ctshow_pma(imgB,(imgB~=0),[0 255],'pma',Rapid_U);
    imshow(imgB);
    title(classB);
    
    p3 = subplot(223);
    %[~,cm3,~] = ctshow_pma(imgC,(imgC~=0),[0 255],'pma',Rapid_U);
    imshow(imgC);
    title(classC);
    
    p4 = subplot(224);
    %[~,cm4,~] = ctshow_pma(imgD,(imgD~=0),[0 255],'pma',Rapid_U);
    imshow(imgD);
    title(classD);
    
    colormap(p1, Rapid_U);
    colormap(p2, Rapid_U);
    colormap(p3, Rapid_U);
    colormap(p4, Rapid_U);
    
    imgtitle = strcat(savename,'_Real'); sgtitle(strrep(imgtitle,'_','\_'));
    %f = getframe;
    saveas(gcf,fullfile(realpath,strcat(imgtitle,'.png')));
    
    imwrite(ncctimg,fullfile(ncctpath,strcat(savename,'.png')));
    close all;
    fprintf('Done with %s\n',savename);
end
% end
disp('Completed')
