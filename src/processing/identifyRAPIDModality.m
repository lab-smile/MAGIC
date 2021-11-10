function modality_name = identifyRAPIDModality(map_img, TTP_test, rCBV_test, rCBF_test, MTT_test)
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
    