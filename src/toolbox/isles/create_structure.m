function create_structure(synPath, testPath, outputPath)
%% Gets output of model and creates structure for the ISLES 2018 model.
% Expects copied from test folder and the result folder.


%% Add utilitie functions to the path
current_directory = pwd();
cd("../utilities")
utilities = pwd();
cd(current_directory)

p_deident = genpath(utilities);
addpath(p_deident);

%%
patients = strings();
caseNum = 1;

fileID = fopen(strcat(outputPath, 'inference.txt'), 'w');

synPath = create_path(synPath);
testPath = create_path(testPath);
outputPath = create_path(outputPath);

dataset = dir(synPath);
dataset = fix_dir(dataset);

for i = 1:length(dataset)
    curPatient = dataset(i).name(1:8);
    
    if sum(ismember(curPatient, patients)) == 1
        continue;
    end
    
    patients = [patients; curPatient];
    
    ncctVolume = getNCCTVolume(strcat(testPath, curPatient));
    [mttVolume, tmaxVolume, cbfVolume, cbvVolume] = create_volumes(strcat(testPath, curPatient), 0);
    [mttSVolume, tmaxSVolume, cbfSVolume, cbvSVolume] = create_volumes(strcat(synPath, curPatient), 1);
    
    mkdir(strcat(outputPath, strcat("case_",num2str(caseNum))));
    niftiwrite(ncctVolume, strcat(outputPath, "case_", num2str(caseNum), '/', curPatient, '_ncct'));
    niftiwrite(mttSVolume, strcat(outputPath, "case_", num2str(caseNum), '/',curPatient, '_smtt'));
    niftiwrite(tmaxSVolume, strcat(outputPath, "case_", num2str(caseNum), '/',curPatient, '_stmax'));
    niftiwrite(cbfSVolume, strcat(outputPath, "case_", num2str(caseNum), '/',curPatient, '_scbf'));
    niftiwrite(cbvSVolume, strcat(outputPath, "case_", num2str(caseNum), '/',curPatient, '_scbv'));

    fprintf(fileID, "%s\n", strcat('inference/', "case_", num2str(caseNum), '/', curPatient, '_ncct.nii'));
    fprintf(fileID, "%s\n",strcat('inference/', "case_", num2str(caseNum), '/', curPatient, '_scbf.nii'));
    fprintf(fileID, "%s\n",strcat('inference/', "case_", num2str(caseNum), '/', curPatient, '_scbv.nii'));
    fprintf(fileID, "%s\n", strcat('inference/', "case_", num2str(caseNum), '/', curPatient, '_smtt.nii'));
    fprintf(fileID, "%s\n",strcat('inference/', "case_", num2str(caseNum), '/', curPatient, '_stmax.nii'));
    fprintf(fileID, "\n");
    
    caseNum = caseNum + 1;
    
    mkdir(strcat(outputPath, strcat("case_",num2str(caseNum))));
    niftiwrite(ncctVolume, strcat(outputPath, "case_", num2str(caseNum), '/', curPatient, '_ncct'));
    niftiwrite(mttVolume, strcat(outputPath, "case_", num2str(caseNum), '/',curPatient, '_mtt'));
    niftiwrite(tmaxVolume, strcat(outputPath, "case_", num2str(caseNum), '/',curPatient, '_tmax'));
    niftiwrite(cbfVolume, strcat(outputPath, "case_", num2str(caseNum), '/',curPatient, '_cbf'));
    niftiwrite(cbvVolume, strcat(outputPath, "case_", num2str(caseNum), '/',curPatient, '_cbv'));
    
    fprintf(fileID, "%s\n", strcat('inference/', "case_", num2str(caseNum),'/', curPatient, '_ncct.nii'));
    fprintf(fileID, "%s\n", strcat('inference/', "case_", num2str(caseNum),'/', curPatient, '_cbf.nii'));
    fprintf(fileID, "%s\n", strcat('inference/', "case_", num2str(caseNum), '/',curPatient, '_cbv.nii'));
    fprintf(fileID, "%s\n", strcat('inference/', "case_", num2str(caseNum), '/',curPatient, '_mtt.nii'));
    fprintf(fileID, "%s\n",strcat('inference/', "case_", num2str(caseNum), '/',curPatient, '_tmax.nii'));
    fprintf(fileID, "\n");
    
    caseNum = caseNum + 1;
   
    
end
end