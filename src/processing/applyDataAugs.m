clc; clear; close all;
imgpath = fullfile('C:/Users/Garrett/Desktop/training_data_aug');
indicpath = fullfile('C:/Users/Garrett/Desktop/indication_lists.xlsx');
idmappath = fullfile('C:/Users/Garrett/Desktop/id_mapping.xlsx');
savepath = fullfile('C:/Users/Garrett/Desktop/augmented_train_data');

if ~exist(savepath,'dir'), mkdir(savepath); end

indic = readtable(indicpath);
idmap = readtable(idmappath); idmap = idmap(:,1:2);
imgs = dir(imgpath);
im_length = length(imgs);
parfor i = 1:im_length
    fprintf('%g of %g\n', i, im_length);
    img = imgs(i);
    if strcmp(img.name(1),'.'), continue; end
    new_id = img.name(1:8);
    ind_id = find(strcmp(new_id,idmap.new_ids)); old_id = string(table2cell(idmap(ind_id,1)));
    ind_indic = find(strcmp(old_id,indic.patientIDs));
    ischemic = indic.list_1(ind_indic); 
    infarct = indic.list_2(ind_indic);
    if infarct% || ischemic
        pix = imread(fullfile(img.folder, img.name));
        imgs_aug = applyaugs(pix, 'unhealthy');
        [~,imgname,ext] = fileparts(img.name);
        savename = fullfile(savepath,imgname);
        imwrite(imgs_aug.img_original, strcat(savename,'_0', ext));
        imwrite(imgs_aug.img_reflected, strcat(savename,'_1', ext));
        imwrite(imgs_aug.img_rot1, strcat(savename,'_2', ext));
        imwrite(imgs_aug.img_rot2, strcat(savename,'_3', ext));
        imwrite(imgs_aug.img_ref_rot1, strcat(savename,'_4', ext));
        imwrite(imgs_aug.img_ref_rot2, strcat(savename,'_5', ext));
        imwrite(imgs_aug.orig_t1, strcat(savename,'_6', ext));
        imwrite(imgs_aug.orig_t2, strcat(savename,'_7', ext));
        imwrite(imgs_aug.ref_t1, strcat(savename,'_8', ext));
        imwrite(imgs_aug.ref_t2, strcat(savename,'_9', ext));
        imwrite(imgs_aug.orig_rot_t1, strcat(savename,'_10', ext));
        imwrite(imgs_aug.orig_rot_t2, strcat(savename,'_11', ext));
        imwrite(imgs_aug.ref_rot_t1, strcat(savename,'_12', ext));
        imwrite(imgs_aug.ref_rot_t2, strcat(savename,'_13', ext));
        %fprintf('Saving %s\n',imgname);
    else
        pix = imread(fullfile(img.folder, img.name));
        imgs_aug = applyaugs(pix, 'healthy');
        [~,imgname,ext] = fileparts(img.name);
        savename = fullfile(savepath,imgname);
        imwrite(imgs_aug.img_reflected, strcat(savename,'_1', ext));
        imwrite(imgs_aug.img_original, strcat(savename,'_0', ext));
        %fprintf('Saving %s\n',imgname)
    end
    %copyfile(fullfile(img.folder,img.name),savepath);
end
disp('all done');


