function outputInfo = di_rmRadReportPHI(fileInfo,newDate,newStudyUID)
%DI_RMRADREPORTPHI   Remove PHI present in Radiology Report in a given
%                    CT DICOM series.
%   
% Calls to this function will remove & edit PHI in the header of the 
% radiology report as well as the body (text) of the radiology report.
% In the text, this function removes references to prior study dates and
% references to the Physician's name.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------

try
    fileInfo.VerifyingObserverSequence.Item_1.VerifyingObserverName = '';
    fileInfo.ContentSequence.Item_4.PersonName = '';
    fileInfo.ContentSequence.Item_2.PersonName = '';
    fileInfo.ContentSequence.Item_3.UID = newStudyUID;
catch
end


% Remove date information & physician's name
for jj = 1:10
    try
        % Find date format in text block
        text = fileInfo.ContentSequence.Item_5.ContentSequence.Item_1.TextValue;
        dateMatch = regexp(text, '\d{2}/\d{2}/\d{4}', 'match');
        if isempty(dateMatch)
            dateMatch = regexp(text, '\d{1}/\d{2}/\d{4}', 'match');
            if isempty(dateMatch)
                dateMatch = regexp(text, '\d{2}/\d{1}/\d{4}', 'match');
                if isempty(dateMatch)
                    dateMatch = regexp(text, '\d{1}/\d{1}/\d{4}', 'match');
                end
            end
        end
        if ~isempty(dateMatch)
            formatnewDate = strcat(newDate(5:6),'-',newDate(7:8),'-',newDate(1:4));
            newText = regexprep(text, dateMatch{1}, formatnewDate);
            fileInfo.ContentSequence.Item_5.ContentSequence.Item_1.TextValue = newText;
        end
    catch
    end
    
    try
        % Find name format in text block
        newText = fileInfo.ContentSequence.Item_5.ContentSequence.Item_1.TextValue;
        breaks = ismember(newText, char([10 13]));
        breaks = find(breaks==1);
        nameMatch = regexp(newText,'MD,');
        if isempty(nameMatch)
            nameMatch = regexp(newText,'Dr.');
            if isempty(nameMatch)
                nameMatch = regexp(newText,'Dr');
                if isempty(nameMatch)
                    nameMatch = regexp(newText,'I, ');
                end
            end
        end
        [~,closestIndex] = min(abs(breaks-nameMatch));
        
        if closestIndex == size(breaks,2)
            newText(breaks(closestIndex):end) = [];
        elseif nameMatch > breaks(closestIndex)
            newText(breaks(closestIndex):breaks(closestIndex+1)) = [];
        else
            newText(breaks(closestIndex-1):breaks(closestIndex)) = [];
        end
        
        breaks2 = ismember(newText, char([10 13]));
        breaks2 = find(breaks2==1);
        lastbreak = breaks2(end);
        
        if contains(newText(lastbreak:end),'findings') && (length(newText)-lastbreak)<15
            newText(lastbreak:end) = [];
        end
        
        fileInfo.ContentSequence.Item_5.ContentSequence.Item_1.TextValue = newText;
    catch
    end
end

outputInfo=fileInfo;
end


