function diceVals = calculate_dice(synNifti, gtNifti, threshold, save_path, save_figs)
%% 
% Helper Function for generate_dice.m
%%
niftiDim = size(synNifti);

diceVals = zeros(1,niftiDim(3));

binaryMaskSyn = false(niftiDim(1), niftiDim(2), niftiDim(3));
binaryMaskGt = false(niftiDim(1), niftiDim(2), niftiDim(3));

for i = 1:niftiDim(3)
    
    synMask = zeros(256,256); gtMask = zeros(256,256);
    synMask = synNifti(:,:,i) > threshold;
    gtMask = gtNifti(:,:,i) > threshold;
    binaryMaskSyn(:, :, i) = synMask;
    binaryMaskGt(:, :, i) = gtMask;
    
    if(save_figs == 1)
        fig = figure('visible', 'off');
        subplot(1,2,1); imshow(binaryMaskGt(:,:,i)); title("Real CTP Segmentation");
        subplot(1,2,2); imshow(binaryMaskSyn(:,:,i)); title("Synthesized CTP Segmentation");

        saveas(fig, strcat(save_path,'_', num2str(i)), 'png'); close all;
    end
    
    diceVals(i) = dice(binaryMaskSyn(:,:,i), binaryMaskGt(:,:,i));
end


end