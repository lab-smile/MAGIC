## [0.0.0] - 2023-05-26
Initial changelog commit
### Added
- New function `fixStudy.m' to fix directories from DICOM-deidentification. Combines multiple study folders.
- New function `splitData.m` splits the subjects using hold out with validation. Multiple images are stratified.
- Added comments and descriptions to `findSliceMatch_RAPID.m`.
- Added comments and descriptions to `newp2pdataset.m`

### Changed
- Renamed some variable names in `findSliceMatch_RAPID.m` to be more intuitive.
- Any references to the utilities now have relative pathing instead of absolute.

### Fixed
- Re-added missing local function "getCorrectImage" to `findSliceMatch_RAPID.m`.