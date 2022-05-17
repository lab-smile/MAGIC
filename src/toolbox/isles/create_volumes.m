function [mttVolume, tmaxVolume, cbfVolume, cbvVolume] = create_volumes(path, synthesized)

num_im = 0;
all_im = cell(1,10);
im_iter = 1;


if(synthesized == 1)
    for i = 1:10
        try
            temp_im = rgb2gray(imread(strcat(path,'_', num2str(i), '_output.png')));
            all_im{im_iter} = temp_im;
            num_im = num_im + 1;
            im_iter = im_iter + 1;
        catch err
        end
    end
    
    offset = 0;
else 
    for i = 1:10
        try
            temp_im = rgb2gray(imread(strcat(path,'_', num2str(i), '.bmp')));
            all_im{im_iter} = temp_im;
            num_im = num_im + 1;
            im_iter = im_iter + 1;
        catch err
        end
    end
    
    offset = 256;
end

mttVolume = zeros(256,256,num_im);
tmaxVolume = zeros(256,256,num_im);
cbfVolume = zeros(256,256,num_im);
cbvVolume = zeros(256,256,num_im);

for i = 1:num_im
    temp_im = all_im{i};
    mttVolume(:,:,i) = temp_im(1:256, 1 + offset:256 + offset);
    tmaxVolume(:,:,i) = temp_im(1:256, 257 + offset:512 + offset);
    cbfVolume(:,:,i) = temp_im(1:256, 513 + offset:768 + offset);
    cbvVolume(:,:,i) = temp_im(1:256, 769 + offset:1024 + offset);
end

end