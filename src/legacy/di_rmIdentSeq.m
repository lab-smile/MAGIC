function new_metadata = di_rmIdentSeq(old_metadata,grp,el)
%DI_RMIDENTSEQ   Remove entire identification sequence for a metadata
%                field.
%   
% This function is called within DI_RMMETAPHI to remove the PHI data of a
% DICOM identification sequence while maintaining the original structure of
% the metadata fields.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------

if isnumeric(grp)
    grp = num2str(grp);
end

if isnumeric(el)
    el = num2str(el);
end

new_metadata = old_metadata;

%Person Identification Code Sequence
new_metadata.(dicomlookup(grp,el)).Item_1.(dicomlookup('0040','1101')) = '';
%Person's Address
new_metadata.(dicomlookup(grp,el)).Item_1.(dicomlookup('0040','1102')) = '';
%Person's Phone Numbers
new_metadata.(dicomlookup(grp,el)).Item_1.(dicomlookup('0040','1103')) = '';
%Person's Telecom Information
new_metadata.(dicomlookup(grp,el)).Item_1.(dicomlookup('0040','1104')) = '';

end

