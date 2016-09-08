[![Version     ](https://img.shields.io/gem/v/phtools.svg?style=flat)](https://rubygems.org/gems/phtools)
# PHTOOLS by ANB
A bundle of small CLI tools for arranging, renaming, tagging of the photo and video files. Helps to keep photo-video assets in order.

## Rationale
PHTOOLS is an instrument intended for photographers\photo enthusiasts who:
* own tons of photo-video files and want to keep it in order
* really don't like the way how digital cameras name the files: P1193691.JPG, IMP_1409.JPG, \_DSC1459.ARW etc.
* for photo storage prefer usage of traditional File System (folder structure) instead of "black box" databases of media managers (like iPhoto, Photoshop etc.)
* would like to have date-time-original info in the name of the file
* expects that sorting folder content "by name" will arrange photo-video assets in chronological order
* for some events (wedding, holydays etc.) have photos from different authors and would like to keep visible author name (nik) in the file name
* appreciate the use of internal metadata (EXIF, XMP etc.) beleiving it is the best way to keep context info of the picture
* are Ok with the use of Command Line tools

## Installation
### Install for usage
1. Get the latest [ruby](https://www.ruby-lang.org/) (>= 2.3) installed.
2. Install ExifTool by Phil Harvey (http://www.sno.phy.queensu.ca/~phil/exiftool/).
3. `gem install phtools`
4. Get list of phtools: `phtools`
5. Get usage info for particular command: `phls -h`

### Install for development
1. Fork or download from GitHub.
2. Install dependencies: `bundle install`
3. Develop.
4. Test:
```sh
bundle exec rspec
bundle exec cucumber
```
... or do testing automatically to get real Test Driven Development:
```sh
bundle exec guard
```

## PHTOOLS Use cases
### Use Case 1. Collect photos, videos, raw-photos from different sources into one place (for further processing)

#### Given
I have copies of SD Cards with photos, videos taken with DSLR camera on my Hard Disk in `~/Desktop/SDCard1` and in `~/Desktop/SDCard2`.

And I have empty folder `~/Desktop/assets_staging` I would like to collect all the photo-files to.

#### When
I run:
```sh
phls -R ~/Desktop/SDCard1 ~/Desktop/SDCard2 | phmove -a ~/Desktop/assets_staging
```

#### Then
I get all photos moved to `~/Desktop/assets_staging`.

And all videos are moved to `~/Desktop/assets_staging/VIDEO`.

And all raw photo-files are moved to `~/Desktop/assets_staging/RAW`.

### Use Case 2. Mass rename photos in accordance with PHTOOLS standard (and don't forget to backup before)

#### Given
I have dozens of photo-files in my working folder `~/Desktop/assets_staging`.

And my friend Alex it the author of the photos (nikname ALX).

#### When
I run:
```sh
cd ~/Desktop/assets_staging
phls | phbackup | phrename -a alx
```

#### Then
I get all photos in `~/Desktop/assets_staging` renamed according to PHTOOLS standard.

And I have all original photo-files are backed-up to `~/Desktop/assets_staging/backup`.


## PHTOOLS concepts
### PHTOOLS Standard file name
PHTOOLS standard file name looks like this: **`YYYYmmdd-HHMMSS_AAA ORIGINAL.EXT`**, where

**YYYYmmdd-HHMMSS** - photo creation datestamp (year-month-day-hours-minutes-seconds). By default PHTOOLS use the value of EXIF tag `DateTimeOriginal` or `CreateDate` for this purpose.

**AAA** - author nikname. 3 character long, only latin alphabet supported.

**ORIGINAL.EXT** - original file name, created by digital camera.

For example, the digital camera photo file `P1193691.JPG`, taken by AndrewBiz (aka ANB), after PHTOOLS processing will look like:
`20160902-174939_ANB P1193691.JPG`
