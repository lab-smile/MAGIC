function ratio = get_ratio(im)
%% Function Header
% Description:
%   Finds the ratios of infarct core volume to tissue at risk volume
%   determined by the Rapid CBF Mismatch. This ratio is also referred to as 
%   the mismatch ratio
%
% Comments:
%   The code does two checks of note: It checks for if the ratio is
%   infinity and NaN. The first case occurs when there is Infarct Core and
%   no Tissue at Risk the second occurs if there is neither Infarct Core or
%   Tissue at Risk.
%   Both of these cases are handled by returning 0
%   
%   It might be of value to allow for Inf to get passed and catch these
%   cases as it might be indicative of a bad example, or it could be the
%   Rapidai bugging.
%
% Inputs:
%   Im : The Rapid CBF Mismatch image - 1283 by 2048 by 3 (RGB image)
%
% Output:
%   The ratio of the volume of infarct core to tissue at risk of the 14
%   z-slices.
%
% Written by : Simon Kato
%              Smile-LAB @UF
%% Function

% Extract the 14 CBF images
CBF1 = im(1:256,1:256,:); CBF2 = im(1:256,257:512,:);
CBF3 = im(1:256,513:768,:); CBF4 = im(1:256,769:1024,:);
CBF5 = im(257:512,1:256,:); CBF6 = im(257:512,257:512,:);
CBF7 = im(257:512,513:768,:); CBF8 = im(257:512,769:1024,:);
CBF9 = im(513:768,1:256,:); CBF10 = im(513:768,257:512,:);
CBF11 = im(513:768,513:768,:); CBF12 =im(513:768,769:1024,:);
CBF13 = im(769:1024,1:256,:); CBF14 = im(769:1024,257:512,:);

% Extract the 14 TMAX images
TMAX1 = im(1:256, 1025:1280,:); TMAX2 = im(1:256,1281:1536,:);
TMAX3 = im(1:256,1537:1792,:); TMAX4 = im(1:256,1793:2048,:);
TMAX5 = im(257:512,1025:1280,:); TMAX6 = im(257:512,1281:1536,:);
TMAX7 = im(257:512,1537:1792,:); TMAX8 = im(257:512,1793:2048,:);
TMAX9 = im(513:768,1025:1280,:); TMAX10 = im(513:768,1281:1536,:);
TMAX11 = im(513:768,1537:1792,:); TMAX12 = im(513:768,1793:2048,:);
TMAX13 = im(769:1024,1025:1280,:); TMAX14 = im(769:1024,1281:1536,:);

% Calculate the volume of Infarct Core and volume of Tissue at risk

ic_slice_volume = [sum(sum(ic_map(CBF1))), sum(sum(ic_map(CBF2))), sum(sum(ic_map(CBF3))), sum(sum(ic_map(CBF4))), sum(sum(ic_map(CBF5))), sum(sum(ic_map(CBF6))), sum(sum(ic_map(CBF7))), sum(sum(ic_map(CBF8))), sum(sum(ic_map(CBF9))), sum(sum(ic_map(CBF10))), sum(sum(ic_map(CBF11))), sum(sum(ic_map(CBF12))), sum(sum(ic_map(CBF13))), sum(sum(ic_map(CBF14)))];
tr_slice_volume = [sum(sum(tr_map(TMAX1))), sum(sum(tr_map(TMAX2))), sum(sum(tr_map(TMAX3))), sum(sum(tr_map(TMAX4))), sum(sum(tr_map(TMAX5))), sum(sum(tr_map(TMAX6))), sum(sum(tr_map(TMAX7))), sum(sum(tr_map(TMAX8))), sum(sum(tr_map(TMAX9))), sum(sum(tr_map(TMAX10))), sum(sum(tr_map(TMAX11))), sum(sum(tr_map(TMAX12))), sum(sum(tr_map(TMAX13))), sum(sum(tr_map(TMAX14)))];


ic_volume = sum(ic_slice_volume);
tr_volume = sum(tr_slice_volume);

ratio = ic_volume/tr_volume;

if(isnan(ratio) || isinf(ratio))
    ratio = 0;
end

end


