function ratios = generate_numeric(realPath, synPath, rapidPath, save_path, save_figs)
%% Function Header
% Description:
%    Find the UQI, SSIM, PSNR, and RMSE of the synthesized and ground truth
%    CTP images at the infarct core and ischemic penumbra regions as found
%    in the CBF Mismatch of the ground truth CTP. Images which do not have
%    ischemic or infarct core will not affect the metrics. 
%
% Comments:
%   The option to save the comparison of CBF, CBV, TTP, and MTT at the
%   bounding boxes for the regions of interests is given. 
%
% Inputs:
%   realPath: the path to the ground truth CTP images. Expected format is a
%   single BMP file with 256x256 images of each modality with the following
%   ordering from left to right: NCCT->MTT->TTP->CBV->CBF. Test set feed
%   into model
%
%   synPath: the path to the synthesized CTP images. Expected format is a
%   single PNG file with 256x256 images of each modality with the following
%   ordering from left to right: MTT->TTP->CBV->CBF. Raw output of the
%   model.
%
%   rapidPath: the path to the rapid data for the patients. This code
%   expects that each patient has rapid data and that patients can be found
%   using the mapping in the utility folder. This mapping was used when
%   going from original folder names to patient names.
%
%   save_path: If you wish to save figures, the desination folder
%
%
%   save_figs: 0 or 1 to identify whether to save figures or not. 0 does
%   not and 1 does.
%
% Output:
%   A table with the SSIM, RMSE, UQI, and PSNR where the first row
%   corresponds to tissue at risk region and the second row to infarct core
%   region. The columns from left to right correspond to MTT -> TTP -> CBV
%   -> CBF for each of the metrics.
%
% Written by : Simon Kato
%              Smile-LAB @UF
%% Add utilitie functions to the path
current_directory = pwd();
cd("../utilities")
utilities = pwd();
cd(current_directory)

p_deident = genpath(utilities);
addpath(p_deident);

%% 
TRSSIM = [0,0,0,0]; ICSSIM = [0,0,0,0];
TRRMSE = [0,0,0,0]; ICRMSE = [0,0,0,0];
TRUQI = [0,0,0,0]; ICUQI = [0,0,0,0];
TRPSNR = [0,0,0,0]; ICPSNR = [0,0,0,0];

connectedCompTR = 0;
connectedCompIC = 0;

allMapping = importdata('id_mapping.xlsx');
allMapping = string(allMapping);

save_path = create_path(save_path);
realImPath = create_path(realPath);
synImPath = create_path(synPath);
rapidPath = create_path(rapidPath);


realIms = dir(realImPath);
realIms = fix_dir(realIms);

synIms = dir(synImPath);
synIms = fix_dir(synIms);

for i = 1: length(realIms)
    
    curIm = realIms(i);
    
    mapped_folder = allMapping(mod(find(allMapping == curIm.name(1:8)), length(allMapping)));
    tempDirs = dir(fullfile(rapidPath, mapped_folder));
    
    tempDirs = fix_dir(tempDirs);
    tempDir = tempDirs(1);
    
    subDirs = dir(fullfile(rapidPath, mapped_folder , '/', tempDir.name));
    subDirs = fix_dir(subDirs);
    
    for j = 1 : length(subDirs)
        tempName = subDirs(j).name;
        tempName = replace(tempName,' ','_');
         if strcmp(tempName, 'RAPID_CT-P_Summary')
            files = dir(fullfile(subDirs(j).folder, '/', subDirs(j).name));
            files = fix_dir(files);

            for fileNum = 1 : length(files)
                curFile = strcat(files(fileNum).folder, '/', files(fileNum).name);
                fileIm = dicomread(fullfile(curFile));
                
                if(size(fileIm) == [1283, 2048, 3])
                    TMAX1 = fileIm(1:256, 1025:1280,:); TMAX2 = fileIm(1:256,1281:1536,:);
                    TMAX3 = fileIm(1:256,1537:1792,:); TMAX4 = fileIm(1:256,1793:2048,:);
                    TMAX5 = fileIm(257:512,1025:1280,:); TMAX6 = fileIm(257:512,1281:1536,:);
                    TMAX7 = fileIm(257:512,1537:1792,:); TMAX8 = fileIm(257:512,1793:2048,:);
                    TMAX9 = fileIm(513:768,1025:1280,:); TMAX10 = fileIm(513:768,1281:1536,:);
                    TMAX11 = fileIm(513:768,1793:2048,:); TMAX12 = fileIm(513:768,1537:1792,:);
                    TMAX13 = fileIm(769:1024,1025:1280,:);
                    
                    CBF1 = fileIm(1:256,1:256,:); CBF2 = fileIm(1:256,257:512,:);
                    CBF3 = fileIm(1:256,513:768,:); CBF4 = fileIm(1:256,769:1024,:);
                    CBF5 = fileIm(257:512,1:256,:); CBF6 = fileIm(257:512,257:512,:);
                    CBF7 = fileIm(257:512,513:768,:); CBF8 = fileIm(257:512,769:1024,:);
                    CBF9 = fileIm(513:768,1:256,:); CBF10 = fileIm(513:768,257:512,:);
                    CBF11 = fileIm(513:768,513:768,:); CBF12 =fileIm(513:768,769:1024,:);
                    CBF13 = fileIm(769:1024,1:256,:); 
                    
                    TMAX = {TMAX1, TMAX2, TMAX3, TMAX4, TMAX5, TMAX6, TMAX7, TMAX8, TMAX9, TMAX10, TMAX11, TMAX12, TMAX13};
                    CBF = {CBF1, CBF2, CBF3, CBF4, CBF5, CBF6, CBF7, CBF8, CBF9, CBF10, CBF11, CBF12, CBF13};
                    break;
                end
            end
            
         break;
         end
    end
    
    sliceStr = curIm.name(10:11);
    if strcmp(sliceStr(end),'.')
        sliceStr = sliceStr(1);
    end
    
    sliceNum = str2num(sliceStr);
    
    tr_mask = tr_map(TMAX{1, sliceNum+3});
    ic_mask = ic_map(CBF{1, sliceNum+3});
    
    if (sum(sum(tr_mask))) == 0
      continue;  
    end
    
    realImage = imread(strcat(realIms(i).folder, '/', realIms(i).name));
    realImage = realImage(1:256,256:1280,:);
    synImage = imread(strcat(synIms(i).folder, '/', synIms(i).name));
    
    tr_bounding_box = regionprops(tr_mask, 'BoundingBox');
    
    if(save_figs == 1)
        fig = figure('visible', 'off');
        subplot(3,1,1); imshow(TMAX{1, sliceNum+3}); title("Tissue At Risk");
        subplot(3,1,2); imshow(realImage); title("Real CTP");
        subplot(3,1,3); imshow(synImage); title("Synthesized CTP");

        saveas(fig, strcat(save_path, curIm.name(1:9),'TR_',  sliceStr), 'png'); close all;
    end
    
    for k = 1:length(tr_bounding_box)
        connectedCompTR = connectedCompTR + 1;
        [imSSIM, imRMSE, imUQI, imPSNR] = compare_images(realImage, synImage, tr_bounding_box(k), strcat(save_path ,curIm.name(1:9), 'tr_',  sliceStr, '_', num2str(k)), save_figs);
        TRSSIM = TRSSIM + imSSIM;
        TRRMSE = TRRMSE + imRMSE;
        TRUQI = TRUQI + imUQI;
        if (imPSNR(1) == Inf || imPSNR(2) == Inf || imPSNR(3) == Inf || imPSNR(4) == Inf)
            imPSNR = TRPSNR/(connectedCompTR-1);
        end
        TRPSNR = TRPSNR + imPSNR;
    end
    
    if (sum(sum(ic_mask))) == 0
      continue;  
    end
    
    ic_bounding_box = regionprops(ic_mask, 'BoundingBox');
    
    if(save_figs == 1)
        fig = figure('visible', 'off');
        subplot(3,1,1); imshow(CBF{1, sliceNum+3}); title("Infarct Region");
        subplot(3,1,2); imshow(realImage); title("Real CTP");
        subplot(3,1,3); imshow(synImage); title("Synthesized CTP");

        saveas(fig, strcat(save_path, curIm.name(1:9), 'IC_',  sliceStr), 'png'); close all;
    end
    
    for k = 1:length(ic_bounding_box)
        connectedCompIC = connectedCompIC + 1;
        [imSSIM, imRMSE, imUQI, imPSNR] = compare_images(realImage, synImage, ic_bounding_box(k), strcat(save_path ,curIm.name(1:9), 'ic_',  sliceStr, '_', num2str(k)), save_figs);
        ICSSIM = ICSSIM + imSSIM;
        ICRMSE = ICRMSE + imRMSE;
        ICUQI = ICUQI + imUQI;
        if (imPSNR(1) == Inf || imPSNR(2) == Inf || imPSNR(3) == Inf || imPSNR(4) == Inf)
            imPSNR = ICPSNR/(connectedCompIC-1);
        end
        ICPSNR = ICPSNR + imPSNR;
    end
   
end
SSIM = [TRSSIM/connectedCompTR; ICSSIM/connectedCompIC];
RMSE = [TRRMSE/connectedCompTR; ICRMSE/connectedCompIC];
UQI = [TRUQI/connectedCompTR; ICUQI/connectedCompIC];
PSNR = [TRPSNR/connectedCompTR; ICPSNR/connectedCompIC];
ratios = table(SSIM,RMSE, UQI, PSNR);
ratios.Properties.VariableNames = {'SSIM', 'RMSE', 'UQI', 'PSNR'};
ratios

end
