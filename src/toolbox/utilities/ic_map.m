function binaryMask = ic_map(im)
%% Function Header
% Description:
%   Finds a binary mask for infarct core region from a 256x256x3 CBF
%   image segmented from the Rapid CBF Mismatch image
%
% Inputs:
%   Im : 256 by 256 by 3 CBF image (RGB CBF image)
%
% Output:
%   binaryMask : returns a 256 by 256 binary map of where there is infarct
%   core, this is the region of the CBF image which is purple.
%
% Written by : Simon Kato
%              Smile-LAB @UF
%% Function
dim = size(im);

binaryMask = false(dim(1), dim(2));
binaryMask(im(:,:,1) == 255 & im(:,:,2) == 0 & im(:,:,3) == 255) = true;
end

