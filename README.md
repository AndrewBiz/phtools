[![Version     ](https://img.shields.io/gem/v/phtools.svg?style=flat)](https://rubygems.org/gems/phtools)
# PHTOOLS by ANB
A bundle of small CLI tools for arranging, renaming, tagging of the photo and video files. Helps keep photo-video assets in order.

##Installation
### Install for usage
Get the latest [ruby](https://www.ruby-lang.org/) (>= 2.3) installed.

Install ExifTool by Phil Harvey (http://www.sno.phy.queensu.ca/~phil/exiftool/)
```
gem install phtools
```
### Install for development
Fork or download from GitHub.

```sh
bundle install
```
Develop, test:
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

####Given 
I have copies of SD Cards with photos, videos taken with DSLR camera on my Hard Disk in `~/path/to/copy/SDCard1` and in `~/path/to/copy/SDCard2`.

And I have empty folder `~/Desktop/assets_staging` I would like to collect all the photo-files to.

####When 
I run:
```sh
cd ~/Desktop/assets_staging
phls -r ~/path/to/copy/SDCard1 ~/path/to/copy/SDCard2 | phmove -a
```

####Then 
I get all photos moved to `~/Desktop/assets_staging`.

And all videos are moved to `~/Desktop/assets_staging/VIDEO`.

And all raw photo-files are moved to `~/Desktop/assets_staging/RAW`.
