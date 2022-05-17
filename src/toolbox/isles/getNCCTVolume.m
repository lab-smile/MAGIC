function ncctVolume = getNCCTVolume(path)

num_im = 0;
all_im = cell(1,10);
im_iter = 1;

for i = 1:10
    try
        temp_im = rgb2gray(imread(strcat(path,'_', num2str(i),'.bmp')));
        all_im{im_iter} = temp_im;
        num_im = num_im + 1;
        im_iter = im_iter + 1;
    catch err
    end
end

ncctVolume = zeros(256,256,num_im);

for i = 1:num_im
    temp_im = all_im{i};
    ncctVolume(:,:,i) = temp_im(1:256, 1:256);
end

end