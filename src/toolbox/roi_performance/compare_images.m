function [SSIM, RMSE, UQI, PSNR] = compare_images(realIm, synIm, bounding_box_coor, save_path, save_figs)
bounding_box_coor = round(bounding_box_coor.BoundingBox);

mttReal = realIm(1:256, 1:256, :); mttSyn = synIm(1:256, 1:256, :);

newRealMTT = mttReal(bounding_box_coor(2):bounding_box_coor(2) + bounding_box_coor(4) - 1, bounding_box_coor(1):bounding_box_coor(1) + bounding_box_coor(3) - 1,:);
newSynMTT = mttSyn(bounding_box_coor(2):bounding_box_coor(2) + bounding_box_coor(4) - 1, bounding_box_coor(1):bounding_box_coor(1) + bounding_box_coor(3) - 1, :);

ttpReal = realIm(1:256, 257:512, :); ttpSyn = synIm(1:256, 257:512, :);

newRealTTP = ttpReal(bounding_box_coor(2):bounding_box_coor(2) + bounding_box_coor(4) - 1, bounding_box_coor(1):bounding_box_coor(1) + bounding_box_coor(3) - 1,:);
newSynTTP = ttpSyn(bounding_box_coor(2):bounding_box_coor(2) + bounding_box_coor(4) - 1, bounding_box_coor(1):bounding_box_coor(1) + bounding_box_coor(3) - 1, :);

cbfReal = realIm(1:256, 513:768, :); cbfSyn = synIm(1:256, 513:768, :);

newRealCBF = cbfReal(bounding_box_coor(2):bounding_box_coor(2) + bounding_box_coor(4) - 1, bounding_box_coor(1):bounding_box_coor(1) + bounding_box_coor(3) - 1,:);
newSynCBF = cbfSyn(bounding_box_coor(2):bounding_box_coor(2) + bounding_box_coor(4) - 1, bounding_box_coor(1):bounding_box_coor(1) + bounding_box_coor(3) - 1, :);

cbvReal = realIm(1:256, 769:1024, :); cbvSyn = synIm(1:256, 769:1024, :);

newRealCBV = cbvReal(bounding_box_coor(2):bounding_box_coor(2) + bounding_box_coor(4) - 1, bounding_box_coor(1):bounding_box_coor(1) + bounding_box_coor(3) - 1,:);
newSynCBV = cbvSyn(bounding_box_coor(2):bounding_box_coor(2) + bounding_box_coor(4) - 1, bounding_box_coor(1):bounding_box_coor(1) + bounding_box_coor(3) - 1, :);

load('RAPID_U.mat');

if(save_figs == 1)
    fig = figure('visible', 'off');
    subplot(2,4,1); imshow(rgb2gray(newRealMTT)); colormap(Rapid_U); title('Real MTT')
    subplot(2,4,2); imshow(rgb2gray(newRealTTP)); colormap(Rapid_U); title('Real TTP')
    subplot(2,4,3); imshow(rgb2gray(newRealCBF)); colormap(Rapid_U); title('Real CBF')
    subplot(2,4,4); imshow(rgb2gray(newRealCBV)); colormap(Rapid_U); title('Real CBV')
    subplot(2,4,5); imshow(rgb2gray(newSynMTT)); colormap(Rapid_U); title('Synthesized MTT')
    subplot(2,4,6); imshow(rgb2gray(newSynTTP)); colormap(Rapid_U); title('Synthesized TTP')
    subplot(2,4,7); imshow(rgb2gray(newSynCBF)); colormap(Rapid_U); title('Synthesized CBF')
    subplot(2,4,8); imshow(rgb2gray(newSynCBV)); colormap(Rapid_U); title('Synthesized CBV')

    saveas(fig, save_path, 'png'); close all;
end


SSIM = [ssim(newSynMTT, newRealMTT), ssim(newSynTTP, newRealTTP), ssim(newSynCBF, newRealCBF), ssim(newSynCBV, newRealCBV)];
RMSE = [sqrt(immse(20*normalize(double(newSynMTT), 'range'), 20*normalize(double(newRealMTT), 'range'))), sqrt(immse(12*normalize(double(newSynTTP), 'range'), 12*normalize(double(newRealTTP), 'range'))), sqrt(immse(60*normalize(double(newSynCBF), 'range'), 60*normalize(double(newRealCBF), 'range'))), sqrt(immse(4*normalize(double(newSynCBV), 'range'), 4*normalize(double(newRealCBV), 'range')))];
UQI = [ssim(newSynMTT, newRealMTT, 'RegularizationConstants', [0 0 0]), ssim(newSynTTP, newRealTTP, 'RegularizationConstants', [0 0 0]), ssim(newSynCBF, newRealCBF, 'RegularizationConstants', [0 0 0]), ssim(newSynCBV, newRealCBV, 'RegularizationConstants', [0 0 0])];
PSNR = [psnr(newSynMTT, newRealMTT), psnr(newSynTTP, newRealTTP), psnr(newSynCBF, newRealCBF), psnr(newSynCBV, newRealCBV)];
end