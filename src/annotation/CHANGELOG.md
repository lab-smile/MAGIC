# Changelog
## [0.1.0] - 2023-03-22
**ct_annotation.m**
- Added erosion feature which separately erodes the top and bottom half of the slice. New erosion settings 'eradius_aif' and 'eradius_vof' control the amount of erosion for AIF and VOF, respectively.
- Changed selectable ROI to fixed ROI. The top of the AIF ROI now begins slightly below the top-most pixel in the slice. The VOF ROI is now centered on the bottom-most pixel.

**ct_extract.m**
- Fixed an issue where both missing and data folders are generated. A check was added to ensure missing folders are only generated once all study folders are examined.

## [0.0.0] - 2023-03-14
- Initial commit