function modality_name = identifyRAPIDModality(map_img, TTP_test, rCBV_test, rCBF_test, MTT_test)
%% Description
% This function identifies the type of perfusion map given a snippet of the
% perfusion map title. The title of the map is not accessible through text
% and only shows up as pixels in the perfusion map. Below is an example.
%   _________________________________
%   |         _____ ______      __  |
%   |        / ____|  _ \ \    / /  |
%   |   _ __| |    | |_) \ \  / /   |
%   |  | '__| |    |  _ < \ \/ /    |
%   |  | |  | |____| |_) | \  /     | 
%   |  |_|   \_____|____/   \/      |
%   |_______________________________| 
% 
% This function identifies the type of perfusion map given an image of the
% name. MTT_test, TTP_test, rCBF_test, and rCBV_test come from
% RAPIDModalities.m. Each of these variables contain a picture containing
% the respective words. Each test name is subtracted from the given input
% to determine the perfusion map type.
% 
%   Garrett Fullerton 10/18/2020
%   Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%   Biomedical Engineering
% 
%   Input:
%       map_img
%----------------------------------------
% Changes
% Last Updated: 5/25/2023
% 5/25/23
% - Added comments and description

%% Main Function

    test_region = map_img(1:30,80:170,:);
    TTP_rank = sum(abs(TTP_test - test_region),'all');
    rCBV_rank = sum(abs(rCBV_test - test_region),'all');
    rCBF_rank = sum(abs(rCBF_test - test_region),'all');
    MTT_rank = sum(abs(MTT_test - test_region),'all');
        
    [~, idx] = min([TTP_rank, rCBV_rank, rCBF_rank, MTT_rank]);
    
    switch idx
        case 1
            modality_name = 'TTP';
        case 2
            modality_name = 'rCBV';
        case 3
            modality_name = 'rCBF';
        case 4
            modality_name = 'MTT';
    end
end
    