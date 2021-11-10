clc; clear; close all;

input_path = fullfile('E:\temps\temp_NCCT');
output_path = fullfile('E:\temps\deident_slicematch_final\NCCT');
ct = 0;

if ~exist(output_path,'dir'), mkdir(output_path); end

patient_dirs = dir(input_path);

for i = 1:length(patient_dirs)
    patient = patient_dirs(i);
    if strcmp(patient.name(1),'.'), continue; end
    subfolders = dir(fullfile(patient.folder,patient.name));        
    
    img_number = 0;
    
    for j = 1:length(subfolders)
        subfolder = subfolders(j);
        if strcmp(subfolder.name(1),'.'), continue; end
        img_files = dir(fullfile(subfolder.folder,subfolder.name));
               
        for k = 1:length(img_files)
            img_file = img_files(k);
            if strcmp(img_file.name(1),'.'), continue; end
            %img_number = str2double(img_file.name(end-8:end-4));
            
            %if isempty(find(img_nums==img_number))
                %img_nums = [
            img_number = img_number+1;
            orig_path = fullfile(img_file.folder,img_file.name);
            
            savename = strcat(patient.name,'_',int2str(img_number),'.bmp');
            save_path = fullfile(output_path,savename);
            %if exist(save_path,'file')
                
            
            movefile(orig_path,save_path);
            ct = ct+1;
            fprintf('Done moving %s\n',savename);
        end
    end
end
disp('Done with everything!');
fprintf('count = %g',ct);
            