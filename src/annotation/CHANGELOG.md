# Changelog
## [0.2.0] - 2023-05
**guide_annotation.docx**
- Added background section as Section 1a
- Added "Recording annotation sessions" and "Navigating the Google Sheets" in Section 3.
- Changed AIF/VOF section from Section 1a -> 1b
- Changed setup section from Section 1b -> 1c
- Changed the order of Section 3. The annotating section was split into two sections. There is now Section 3: Annotating CTP and Section 4: Annotation Walkthrough

## [0.1.0] - 2023-03-22
**ct_annotation.m**
- Added erosion feature which separately erodes the top and bottom half of the slice. New erosion settings `eradius_aif` and `eradius_vof` control the amount of erosion for AIF and VOF, respectively.
- Added a check to see if the user updated the initials. The script is terminated if not updated.
- Changed selectable ROI to fixed ROI. The top of the AIF ROI now begins slightly below the top-most pixel in the slice. The VOF ROI is now centered on the bottom-most pixel.
- Changed how files are deleted and overwritten. All contents are now deleted instead of specific files.

**ct_extract.m**
- Changed which metadata was used. Series number now uses a threshold instead of fixed number. Image comments are now used to exclude sub-adv and stack images if available.
- Fixed an issue where both missing and data folders are generated. A check was added to ensure missing folders are only generated once all study folders are examined.

**guide_annotation.docx**
- Added step in sec.1b to change user-specific variables.

**guide_annotation_visual.pptx**
- Added new visual steps that mirrors section 1b and 3 in `guide_annotation.docx`.

**Standalone Training**
- Replaced the excel sheet with a text file for easier access in MATLAB.

## [0.0.0] - 2023-03-14
- Initial commit