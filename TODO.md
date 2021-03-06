### PHTOOLS Core
- [x] core - runner.rb: print class instance variables in debug mode
- [x] get rid of nesty
- [x] switch to fresh MiniExiftool gem
- [x] support of Apple HEIC files

### phls
- [x] phls: use init method to initialize variables
- [x] phls: change -r to -R
- [x] phls: sort files in alphabet order
- [x] phls: support --range parameter to filter files which belong to the range
- [ ] phls: make it work with .folders (like ftls did)

### phmove
- [x] phmove: create phmove tool based on ftarrange code (see ftools repo)
- [x] phmove: make target_folder as parameter not an option
- [x] phmove: -a (--arrange) parameter means to put photo, video, raw files into separate folders inside target. If -a is not set all files are moved to root of target directory (plain collection of files)
- [x] phmove: delete unused empty RAW and VIDEO folders
- [x] phmove: make default TARGET_FOLDER = .
- [ ] phmove: make options to set video, raw folder names

### phrename
- [x] phrename: add -c --clean option (based on ftclname functionality)
- [x] phrename: add -s --shift_time option (based on ftfixdate functionality)
- [x] phrename: by-default read tags for DateTime in this order: DateTimeOriginal, DateCreated, CreateDate, DigitalCreationDate, FileModifyDate (eqv to File::mtime). 1st non-zero value will be taken as a master photo creation timestamp. It means no longer names like '00000101-000000_ANB IMG_0183.PNG' will appear.
- [x] phrename: make it safe and smart. Once the file was renamed to PHTOOL standard, re-run of phrename should not change the date-time info unless options -t or -s are used. If user wants to reset file name using exif tag - 1st clean it `phrename --clean`, then rename `phrename -a anb`
- [x] phrename: new mode 'manual rename' renames files using given date-time template, author name and prefix. Good for mass renaming of the scanned films and photos (when date-time is not set in the tags and only human knows the real date-time)
- [ ] phrename: make new usage mode: `phrename -t TAG`. Useful if user wants to re-set date-time using TAG keeping author-nickname unchanged
- [ ] phrename: add QuickTime.CreationDate into analysis when calculate date-time-in-the-name (useful for iOS mov files). In iOS QuickTime.CreateDate is wrong (always in Grinvich zone), while QuickTime.CreationDate is Ok

### phgettags
- [x] create phgettags (based on ftmtags)
- [ ] support option -e --composite of exiftool

### phfixfmd
- [x] create phfixfmd - fix FileModifyDate to get equal to date-time-in-the-name

### phfixdto
- [x] create phfixdto - fix MWG:DateTimeOriginal (DTO) := date-time-in-name
- [x] phfixdto: make -N --no_run option = no running exiftool script, only preparation
- [ ] phfixdto: if DateTimeOriginal or CreateDate already equals date-time-in-the-name then don't touch it
- [ ] phfixdto: smartly check if CreateDate set (including MWG subfields). If any - then update CreateDate

### phevent
- [ ] create phevent  (based on ftevent)
- [ ] phevent: -T --template - gets empty template for event.yaml

### phsettags
- [ ] create phsettags (based on fttagset)
- [ ] phsettags: make -N --no_run option = no running exiftool script, only preparation
- [ ] phsettags: -T --template - gets empty templates for authors.yaml and places.yaml
