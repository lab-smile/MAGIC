folders = {{'MTT'}, {'rCBF'}, {'TTP'}};

for i = 1:length(folders)
inputfolderroot = 'C:\Users\Garrett\Desktop\all_ncct_data\';
inputfolder = fullfile(inputfolderroot, cell2mat(folders{i}));
imfiles = dir(inputfolder);
load('Rapid_Colormap.mat'); c_map = Rapid_U;


for i = 1:length(imfiles)-1
    img1 = imfiles(i);
    if strcmp(img1.name(1),'.'),continue;end
    img2 = imfiles(i+1);
    im1 = imread(fullfile(img1.folder,img1.name));
    im2 = imread(fullfile(img2.folder,img2.name));
    imout = make9images(im1,im2);
    for k = 1:size(imout,3)
        timg = imout(:,:,k);
        figure; imshow(timg); colormap(c_map);
        f = getframe;
        savename = strcat(img1.name,'_',img2.name,'_',num2str(k),'.bmp');
        savepath = fullfile(img1.folder,savename);
        imwrite(f.cdata,savepath);
        close all
    end
end
disp('all done');
end
        
        
