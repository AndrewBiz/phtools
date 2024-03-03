[![Version     ](https://img.shields.io/gem/v/phtools.svg?style=flat)](https://rubygems.org/gems/phtools)

# PHTOOLS by ANB

A bundle of small CLI tools for arranging, renaming, tagging of the photo and video files. Helps to keep photo-video assets in order.

## Rationale

PHTOOLS is an instrument intended for photographers\photo enthusiasts who:

- own tons of photo-video files and want to keep it in order
- really don't like the way how digital cameras name the files: P1193691.JPG, IMP_1409.JPG, \_DSC1459.ARW etc.
- for photo storage prefer usage of traditional File System \(folder structure\) instead of "black box" databases of media managers \(like iPhoto, Photoshop etc.\)
- would like to have date-time-original info in the name of the file
- expects that sorting folder content "by name" will arrange photo-video assets in chronological order
- for some events \(wedding, holydays etc.\) have photos from different authors and would like to keep visible author name \(nik\) in the file name
- appreciate the use of internal metadata \(EXIF, XMP etc.\) beleiving it is the best way to keep context info of the picture
- are Ok with the use of Command Line tools

---

## Installation

### Install for usage

1. Get the latest [ruby](https://www.ruby-lang.org/) \(&gt;= 3.0\) installed.
2. Install ExifTool by Phil Harvey \([http://www.sno.phy.queensu.ca/~phil/exiftool/](http://www.sno.phy.queensu.ca/~phil/exiftool/)\).
3. `gem install phtools`
4. Get list of phtools: `phtools`
5. Get usage info for particular command: `phls -h`

### Install for development

1. Fork or download from GitHub.
2. Install dependencies:

   ```sh
   bundle install
   ```

3. Develop.
4. Test:
   ```sh
   bundle exec rspec
   bundle exec cucumber
   ```

---

## PHTOOLS Use cases

### USE CASE 1. Collect photos, videos, raw-photos from different sources into one place \(for further processing\)

#### Given

I have copies of SD Cards with photos, videos taken with DSLR camera on my Hard Disk in `~/Desktop/SDCard1` and in `~/Desktop/SDCard2`.

And I have empty folder `~/Desktop/assets_staging` \(lets call it _working folder_\).

And I want all the photo-video files from SD copies \(including ones placed deep inside the folder structure of the SD card\) to be moved to the _working folder_.

#### When

I run:

```sh
phls -R ~/Desktop/SDCard1 ~/Desktop/SDCard2 | phmove -a ~/Desktop/assets_staging
```

#### Then

I get all photos moved to `~/Desktop/assets_staging`.

And all videos are moved to `~/Desktop/assets_staging/VIDEO`.

And all raw photo-files are moved to `~/Desktop/assets_staging/RAW`.

==========

### USE CASE 2. Renaming files in accordance with PHTOOLS standard

#### USE CASE 2.1 Mass rename photos in accordance with PHTOOLS standard \(and don't forget to backup before\)

#### Given

I have dozens of photo-files in my working folder `~/Desktop/assets_staging`.

And my friend Alex it the author of the photos \(nikname ALX\).

#### When

I run:

```sh
cd ~/Desktop/assets_staging
phls | phbackup | phrename -a alx
```

#### Then

I get all photos in `~/Desktop/assets_staging` renamed according to PHTOOLS standard.

And I have all original photo-files are backed-up to `~/Desktop/assets_staging/backup`.

==========

#### USE CASE 2.2 Rename photos back to it's original names

#### Given

I have several photo files in my working folder `~/Desktop/assets_staging` renamed to PHTOOLS standard.

And I want to get all the files renamed back to it's original names \(given by DSLR camera\)

#### When

I run:

```sh
cd ~/Desktop/assets_staging
phls | phrename --clean
```

#### Then

I get all photos in `~/Desktop/assets_staging` renamed to it's original names.

==========

#### USE CASE 2.3 Change author nickname in the filenames

#### Given

I have several photo files in my working folder `~/Desktop/assets_staging` renamed to PHTOOLS standard. Some photos were made by ANB, some photos were made by Alex \(nick _ALE_\)

And I want to change the author NICKNAME _ALE_ to _ALX_.

#### When

I run:

```sh
cd ~/Desktop/assets_staging
phls '*ALE*'| phrename -a alx
```

#### Then

I get all _ALE_ photos in `~/Desktop/assets_staging` renamed to _ALX_ nickname.

And all _ANB_ photos are kept unchanged.

_Note. _`phrename`_ is smart enough to let the user to re-run it several times on one file. Every time _`phrename -a`_ re-runs it only overwrites author nickname \(if it is different\) keeping date-time-in-the-name unchanged._

==========

#### USE CASE 2.4 Adjust date-time in the filename

#### Given

I have several video files taken by iPhone in my working folder `~/Desktop/assets_staging` renamed to PHTOOLS standard.

And I've found out that iPhone gives the wrong value to CreateDate tag \(in my case the error is minus 2 hours to real time of creation\). Because of that 'phrename' gives the wrong _YYYYmmdd-HHMMSS_ timestamp in the filename. I want to get the correct date-time info in the names of video files.

#### When

I run:

```sh
cd ~/Desktop/assets_staging
phls '*.mov'| phrename --shift_time 7200
```

#### Then

I get all _mov_ files in `~/Desktop/assets_staging` renamed with correct _YYYYmmdd-HHMMSS_ timestamp \(+ 7200 second = + 2 hours than it was before\).

---

## PHTOOLS concepts

### PHTOOLS Standard file name

PHTOOLS standard file name looks like this: `YYYYmmdd-HHMMSS_AAA ORIGINAL.EXT`, where

**YYYYmmdd-HHMMSS** - photo creation datestamp \(year-month-day-hours-minutes-seconds\). By default PHTOOLS use the value of EXIF tag groups `DateTimeOriginal` or `CreateDate` for this purpose _\(for more details see phrename help: _`phrename -h`_\)_.

**AAA** - author nikname. 3 character long, only latin alphabet supported.

**ORIGINAL.EXT** - original file name, created by digital camera.

For example, the digital camera photo file `P1193691.JPG`, taken by AndrewBiz \(aka ANB\), after PHTOOLS processing will look like:  
`20160902-174939_ANB P1193691.JPG`
