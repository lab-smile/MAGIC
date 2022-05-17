function uid = di_makeUID(studyDate, studyTime, root)
%DI_MAKEUID   Generate a unique DICOM UID.
%   
% Calls to this function will generate a unique DICOM UID sequence to be
% used in assigning SeriesInstanceUID and StudyInstanceUID, among other
% DICOM fields. 
%
% ROOT = DICOM UID root that is unique to the given institution's protocol.
%        This value can be adjusted in the settings section of the main
%        script.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------

if isempty(studyTime)
    pick={'1','2','3','4','5','6','7','8','9'};
    pick1Indexes = randi(length(pick), 1, 6);
    pick2Indexes = randi(length(pick), 1, 3);
    pick1=cell2mat(pick(pick1Indexes));
    pick2=cell2mat(pick(pick2Indexes));
    studyTime=strcat(pick1,'.',pick2);
end

% Generate UID
t_unq = GetUniqTimeOfDay;

if isnumeric(studyDate)
    studyDate = num2str(studyDate);
end

if isstr(studyTime)
    studyTime=str2num(studyTime);
end
studyTime = num2str(floor(studyTime));

while true
    rand_num = num2str(floor(rand * (9990/2)));
    try
        rand_num = rand_num(1:3);
        break;
    catch
    end
end

st = {root,studyDate,studyTime,t_unq,rand_num};
tuid = strjoin(st,'.');

i=1;j=1;dot=0;
while i<=length(tuid)
    if dot
        if strcmp(tuid(i),'0')
            uid(j)='1';
            j=j+1;
        end
        dot=0;
    end
    
    if strcmp(tuid(i),'.')
        dot=1;
    end
    uid(j)=tuid(i);
    i=i+1;
    j=j+1;
end

end


function sec = GetUniqTimeOfDay(~)
% Get a unique time of day
tp = clock;
sec = tp(6);
while true
    t_temp = clock;
    if t_temp(6) ~= sec
        break;
    end
end
sec=sec-fix(sec);
sec=round(sec,3)*1000;
sec=num2str(sec);
end