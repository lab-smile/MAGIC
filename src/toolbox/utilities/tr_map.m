function binaryMask = tr_map(im)
%% Function Header
% Description:
%   Finds a binary mask for tissue at risk region from a 256x256x3 TMAX
%   image segmented from the Rapid CBF Mismatch image
%
% Inputs:
%   Im : 256 by 256 by 3 TMAX image (RGB TMAX image)
%
% Output:
%   binaryMask : returns a 256 by 256 binary map of where there is tissue
%   at risk, this is the region of the TMAX image which is bright green.
%
% Written by : Simon Kato
%              Smile-LAB @UF
%% Function
dim = size(im);

binaryMask = false(dim(1), dim(2));
binaryMask(im(:,:,1) == 0 & im(:,:,2) == 255 & im(:,:,3) == 0) = true;
end

