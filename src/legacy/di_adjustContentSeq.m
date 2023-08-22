function outputStruct = di_adjustContentSeq(inputStruct,UID_root,studyDate,studyTime,studyUID)
%DI_ADJUSTCONTENTSEQ   Remove PHI present in ContentSeq metadata structure.
%   
% This function is called recursively in DI_ADJUSTDOSERPTPHI to remove all
% PHI information within the X-ray radiation dose report and to assign the
% correct StudyInstanceUID within the report.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------
outputStruct = inputStruct;
contentSeq = outputStruct.ContentSequence;
contentFields = fields(contentSeq);

for item = 1:length(contentFields)
    tmpStruct_new = contentSeq.(char(contentFields(item)));
    flag = 0;
    if isfield(tmpStruct_new,'UID')
        if isfield(tmpStruct_new,'ConceptNameCodeSequence')
            tmpConCodeStruct = tmpStruct_new.ConceptNameCodeSequence;
            tmpConCodeFields = fields(tmpConCodeStruct);
            for item2 = 1:length(tmpConCodeFields)
                tmpConFieldStruct = tmpConCodeStruct.(char(tmpConCodeFields(item2)));
                if isfield(tmpConFieldStruct,'CodeMeaning')
                    if strcmp(tmpConFieldStruct.CodeMeaning,'Study Instance UID')
                        flag = 1;
                        break;
                    end
                end
            end
        end
        if ~flag
            newUID = di_makeUID(studyDate,studyTime,UID_root);
            outputStruct.ContentSequence.(char(contentFields(item))).UID = newUID;
        else
            outputStruct.ContentSequence.(char(contentFields(item))).UID = studyUID;
        end
    end
    if isfield(tmpStruct_new,'DateTime')
        outputStruct.ContentSequence.(char(contentFields(item))).DateTime = studyDate;
    end
    if isfield(tmpStruct_new,'ContentSequence')
        outputStruct.ContentSequence.(char(contentFields(item))) = di_adjustContentSeq(tmpStruct_new,UID_root,studyDate,studyTime,studyUID);
    end
end
        
end

