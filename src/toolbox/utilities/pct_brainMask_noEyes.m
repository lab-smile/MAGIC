function newmask = pct_brainMask_noEyes(im,lb,ub,dsize)
% FUNCTION MASK = pct_brainMask_noEyes(IM, LB, UB, DSIZE) finds the brain mask on the given image
% by eliminating negative values and values exceeding the upper limit.
% Additionally, this function removes eyes from CT scans.
%
% INPUT:
%       IM      - Input image [Y x X]
%       LB      - Lower bound (default 0)
%       UB      - Upper bound (default 2000)
%       DSIZE   - Disk radius for morphological closing [Scalar] default:3
%
% OUTPUT:
%       MASK - Brain mask [Logical] (1 for brain region, 0 for non-brain
%       region)
%
% -Ruogu Fang 12/22/2010

if nargin < 2
    lb = 0;
    ub = 2000;
end

if nargin < 4
    dsize = 3;
end

bin = false(size(im));
bin(lb < im & im <= ub) = true;
cc = bwconncomp(bin);
%numPixels = cellfun(@numel,cc.PixelIdxList);
%[~,idx]=max(numPixels);
%mask = false(size(im));
%mask(cc.PixelIdxList{idx})=true;
% mask = false(size(im));
% mask(lb<im & im <=ub)=true;
str = strel('disk',dsize);

% try
%     mid = cellfun(@(x) x(x==140000), cc.PixelIdxList,'UniformOutput',false); %just for testing
%     mid_loc = ~cellfun('isempty',mid);
%     bin2 = false(size(bin));
%     bin2(cc.PixelIdxList{mid_loc})=true;
%     mask = bin2;
% catch    
mask = imclose(bin,str);
%end
mask = imopen(mask,str);
str=strel('disk',9);
mask = imopen(mask,str);

% [~,idxnew]=bwdist(mask);
% pointidx=sub2ind(size(mask),256,256);
% closestpointidx = idxnew(pointidx);

% cc = bwconncomp(mask);
% mid_new = cellfun(@(x) x(x==closestpointidx), cc.PixelIdxList,'UniformOutput',false); %just for testing
% mid_loc_new = ~cellfun('isempty',mid_new);
% newmask = false(size(mask));
% newmask(cc.PixelIdxList{mid_loc_new})=true;

cc = bwconncomp(mask);
numPixels = cellfun(@numel,cc.PixelIdxList);
[~,idx] = max(numPixels);
newmask = false(size(mask));
try
    newmask(cc.PixelIdxList{idx})=true;
    newmask = imclose(newmask,str);
catch
end
newmask = logical(newmask);


% try using imopen -> bwconncomp to find largest component (brain) ->
% imclose
% create in pct_brainMask_noEye.m
end
    
