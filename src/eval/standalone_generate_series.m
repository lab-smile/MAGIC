% This is same as generate_series.m but for compiling as standalone binary
% Differences are:
% 1. Change generate_series to a function that accepts 4 arguments, datapath_real, datapath_fake, outpath, colormap_path
% 2. Remove clear; clc; close all; that are only needed for when running in matlab GUI
% 3. Explicitly set the Pool workers to 2 instead of using default number of workers (equal to CPU count)

function generate_series(datapath_real, datapath_fake, outpath, colormap_path)
    delete(gcp('nocreate')) % delete current parallel pool
    poolobj = parpool('local', 2); % create new pool with 2 workers

    data = load(colormap_path); % returns a struct
    Rapid_U = data.Rapid_U;

    classA = 'MTT';
    classB = 'TTP';
    classC = 'CBF';
    classD = 'CBV';

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
    real_files = dir(fullfile(datapath_real,'*.bmp'));

    %%
    parfor i = 1:length(fake_files)
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
    parfor i = 1:length(real_files)
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

    disp('Completed')

    delete(poolobj); % delete the pool after computation is done
end