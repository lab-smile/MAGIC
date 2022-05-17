function [tr, ic] = get_ratio(im)
%% Function Header
% Description:
%   Finds the ratios of infarct core to tissue at risk determined by the
%   Rapid CBF Mismatch which is a surgote for the two regions
%
% Comments:
%   The code does two checks of note: It checks for if the maximum ratio is
%   infinity and NaN. The first case occurs when there is Infarct Core and
%   no Tissue at Risk the second occurs if there is neither Infarct Core or
%   Tissue at Risk.
%   The case of having neither Infarct Core or Tissue at risk is handled by
%   returning 0
%   The case of having infarct core and tissue at risk is handled by
%   making that entry in the ratios array 0 and pulling from the array
%   again. 
%   It might be of value to allow for Inf to get passed and catch these
%   cases as it might be indicative of a bad example, or it could be the
%   Rapidai bugging.
%
% Inputs:
%   Im : The Rapid CBF Mismatch image - 1283 by 2048 by 3 (RGB image)
%
% Output:
%   The maximum of the 14 z-slice infarct core to tissue at risk ratios
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

% Determine whether any regions exists
tr = false; ic = false;
if(sum(sum(tr_map(TMAX1))) > 0 || sum(sum(tr_map(TMAX2))) > 0 || sum(sum(tr_map(TMAX3))) > 0 || sum(sum(tr_map(TMAX4))) > 0 || sum(sum(tr_map(TMAX5))) > 0 || sum(sum(tr_map(TMAX6))) > 0 || sum(sum(tr_map(TMAX7))) > 0 || sum(sum(tr_map(TMAX8))) > 0 || sum(sum(tr_map(TMAX9))) > 0 || sum(sum(tr_map(TMAX10))) > 0 || sum(sum(tr_map(TMAX11))) > 0 || sum(sum(tr_map(TMAX12))) > 0 || sum(sum(tr_map(TMAX13))) > 0 || sum(sum(tr_map(TMAX14))) > 0)  
    tr = true;
end

if(sum(sum(ic_map(CBF1))) > 0 || sum(sum(ic_map(CBF2))) > 0 || sum(sum(ic_map(CBF3))) > 0 || sum(sum(ic_map(CBF4))) > 0 || sum(sum(ic_map(CBF5))) > 0 || sum(sum(ic_map(CBF6))) > 0 || sum(sum(ic_map(CBF7))) > 0 || sum(sum(ic_map(CBF8))) > 0 || sum(sum(ic_map(CBF9))) > 0 || sum(sum(ic_map(CBF10))) > 0 || sum(sum(ic_map(CBF11))) > 0 || sum(sum(ic_map(CBF12))) > 0 || sum(sum(ic_map(CBF13))) > 0 || sum(sum(ic_map(CBF14))) > 0)
    ic = true;
end
end


