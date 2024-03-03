# RELEASED

## [v0.17.0](https://github.com/andrewbiz/phtools/compare/v0.17.0...v0.16.0)

- cleaned dependancy from old ActiveSupport which had problem - compile error for bigdecimal gem on new ruby versions

## [v0.16.0](https://github.com/andrewbiz/phtools/compare/v0.15.0...v0.16.0)

- phtools now support Apple HEIC image file format (as exiftool it can only read tags)

## [v0.15.0](https://github.com/andrewbiz/phtools/compare/v0.14.0...v0.15.0)

- phls now supports --range parameter allowing the user to filter files which name endings are not in the given range

## [v0.14.0](https://github.com/andrewbiz/phtools/compare/v0.10.0...v0.14.0)

- ruby version required >= 2.4.0
- phmove: now default TARGET_FOLDER is '.'
- added 3gp video files support
- phls: sort files in alphabet order
- phrename: added new mode - manual rename. User sets date-time-in-the-name, increment and header to generate filename
- code refactor (code optimizations, ruby 2.4.2 adaptation, new rubocop rules)

## [v0.10.0](https://github.com/andrewbiz/phtools/compare/v0.8.0...v0.10.0)

- phgettags added to the bundle
- phfixdto added to the bundle

## [v0.8.0](https://github.com/andrewbiz/phtools/compare/v0.7.7...v0.8.0)

- phfixfmd added to the bundle

## [v0.7.7](https://github.com/andrewbiz/phtools/compare/v0.6.0...v0.7.7)

- phrename: added --shift_time option
- phrename is idempotent (safe to be re-run several times on one file)
- phrename: by-default now it scans several EXIF tags to retreive date-time creation info. If no tags are found - File ModifyDate (mtime) is used to rename file. See more details in `phrename -h`
- phrename becomes more informative: reports which EXIF tag was taken, or if the date-time in name was kept unchanged. This flow goes to STDERR to keep STDOUT clean
- phbackup now preserves FileModify dates
- internal improvements: switch to mini_exiftool gem, get rid of nesty gem (using standard Ruby _cause_ for Exceptions)

## [v0.6.0](https://github.com/andrewbiz/phtools/compare/v0.4.0...v0.6.0)

- phmove: does not keep unused empty VIDEO and RAW folders
- phrename: --clean option renames files back to original state
- Added phbackup

## [v0.4.0](https://github.com/andrewbiz/phtools/compare/v0.3.0.pre.alpha...v0.4.0)

- Added description to README.md
- Changed phls - option -R instead of -r (ls compatibility)
- Added phmove command
- Added phrename command

## [v0.3.0.pre.alpha](https://github.com/andrewbiz/phtools/compare/v0.2.4...v0.3.0.pre.alpha)

- Improved phls - now it supports DIRs and FILEMASKs parameters
- Added aruba (cucumber) tests for phls
