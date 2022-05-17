% create nii files
folders = {{'NCCT'},{'rCBV'},{'rCBF'},{'TTP'},{'MTT'}};
inputroot = 'C:/Users/Garrett/Desktop/all_ncct_data';
outputfolder = 'C:/Users/Garrett/Desktop/all_ncct_data/NIFTI';
for i = 1:length(folders)
    modality = cell2mat(folders{i});
    folder = fullfile(inputroot, modality);
    savefolder = fullfile(outputfolder, modality);
    imgs = natsortfiles(dir(folder));
    
    nii_file = [];
    for j = 1:length(imgs)
    pix = imgs(j);
    if strcmp(pix.name(1),'.'), continue; end
    img = imread(fullfile(pix.folder,pix.name));
    nii_file = cat(4, nii_file, img);
    end
    
    if ~exist(savefolder, 'dir'), mkdir(savefolder); end
    niftiwrite(nii_file, savefolder);
end
