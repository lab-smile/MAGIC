function imout = make9images(gim1,gim10)

load('Rapid_Colormap.mat'); c_map = Rapid_U; c_map(2:7,3)=0;
addpath(genpath('C:/Users/Garrett/Desktop/junk drawer/REU/scripts/rgb2values/'));

gim1 = uint8(rgb2values(gim1, c_map, 'gray')); %gim1 = double(gim1);
gim10 = uint8(rgb2values(gim10, c_map, 'gray')); %gim10 = double(gim10);
minpix = mean([min(gim1(:)), min(gim10(:))]);
maxpix = mean([max(gim1(:)), max(gim10(:))]);

img3 = cat(3,im2double(gim1),im2double(gim10)); % 1, 10 -> 5
gim = interp3(img3); gim = rgb2gray(gim);
gim = imresize(gim,[256 256]);
gim = rescale_img(gim); 
gim5 = gim; gim5mask = gim5 == 0;

img3 = cat(3,im2double(gim1),im2double(gim5)); % 1, 5 -> 3
gim = interp3(img3); gim = rgb2gray(gim);gim = imresize(gim,[256 256]);
gim = rescale_img(gim);
gim3 = gim; gim3mask = gim3 == 0;

img3 = cat(3,im2double(gim5),im2double(gim10)); % 5, 10 -> 8
gim = interp3(img3); gim = rgb2gray(gim);gim = imresize(gim,[256 256]);
gim = rescale_img(gim); gim(gim==1)=0;
gim8 = gim; gim8mask = gim8 == 0;

img3 = cat(3,im2double(gim1),im2double(gim3)); % 1, 3 -> 2
gim = interp3(img3); gim = rgb2gray(gim);gim = imresize(gim,[256 256]);
gim = rescale_img(gim); 
gim2 = gim; gim2mask = gim2 == 0;

img3 = cat(3,im2double(gim3),im2double(gim5)); %3, 5 -> 4
gim = interp3(img3); gim = rgb2gray(gim); gim = imresize(gim,[256 256]);
gim = rescale_img(gim);
gim4 = gim; gim4mask = gim4 == 0;

img3 = cat(3,im2double(gim5),im2double(gim8)); %5, 8 -> 6
gim = interp3(img3);  gim = rgb2gray(gim);gim = imresize(gim,[256 256]);
gim = rescale_img(gim);
gim6 = gim; gim6mask = gim6 == 0;

img3 = cat(3,im2double(gim8),im2double(gim10)); %8, 10 -> 9
gim = interp3(img3);  gim = rgb2gray(gim);gim = imresize(gim,[256 256]);
gim = rescale_img(gim);
gim9 = gim; gim9mask = gim9 == 0;

img3 = cat(3,im2double(gim6),im2double(gim8)); %6, 8 -> 7
gim = interp3(img3);gim = rgb2gray(gim); gim = imresize(gim,[256 256]);
gim = rescale_img(gim); 
gim7 = gim; gim7mask = gim7 == 0;

imout = cat(3,gim2, gim3, gim4, gim5, gim6, gim7, gim8, gim9);

% for k = 1:size(imout,3)
%     timg = imout(:,:,k);
%     %figure; imshow(timg); colormap(c_map);
%     %f = getframe;
%     img = ind2rgb(timg,c_map);
%     savename = strcat(num2str(num1),'_',num2str(num2),'_',num2str(k),'.bmp');
%     savepathfin = fullfile(savepath,savename);
%     %imshow(img);
%     imwrite(img,savepathfin);
%     close all
%     fprintf('done with %s\n',savename);
% end
end

function outimg = rescale_img(inimg)
    outimg = 255 * (inimg - min(inimg(:))) / range(inimg(:));
    outimg = uint8(outimg);
end