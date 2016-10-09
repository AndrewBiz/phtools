#!/usr/bin/env bash
echo "Generating sample files with phtools-related tags"
cfile="tag_city1.JPG"
echo "Preparing file $cfile ..."
cp "_template.JPG" "$cfile"
exiftool -P -overwrite_original "-IPTC:City=IPTC-Петербург" "-XMP:City=XMP-Москва" "-XMP:LocationShownCity=XMP-ShownCity" "$cfile"

cfile="tag_city2.JPG"
echo "Preparing file $cfile ..."
cp "_template.JPG" "$cfile"
exiftool -P -overwrite_original "-IPTC:City=" "-XMP:City=XMP-Москва" "-XMP:LocationShownCity=XMP-ShownCity" "$cfile"

cfile="tag_city3.JPG"
echo "Preparing file $cfile ..."
cp "_template.JPG" "$cfile"
exiftool -P -overwrite_original "-IPTC:City=" "-XMP:City=" "-XMP:LocationShownCity=XMP-ShownCity" "$cfile"

# cfile="1exif_datetimeoriginal.JPG"
# echo "Preparing file $cfile ..."
# cp "$@" "$cfile"
# exiftool -P -overwrite_original "-FileModifyDate=2007:07:07 07:07:07" "$cfile"
#
# cfile="2iptc_datecreated.JPG"
# echo "Preparing file $cfile ..."
# cp "$@" "$cfile"
# exiftool -P -overwrite_original "-FileModifyDate=2007:07:07 07:07:07" "-EXIF:DateTimeOriginal=" "$cfile"
#
# cfile="3xmp_datecreated.JPG"
# echo "Preparing file $cfile ..."
# cp "$@" "$cfile"
# exiftool -P -overwrite_original "-FileModifyDate=2007:07:07 07:07:07" "-EXIF:DateTimeOriginal=" "-IPTC:DateCreated=" "-IPTC:TimeCreated=" "$cfile"
#
# cfile="4exif_createdate.JPG"
# echo "Preparing file $cfile ..."
# cp "$@" "$cfile"
# exiftool -P -overwrite_original "-FileModifyDate=2007:07:07 07:07:07" "-EXIF:DateTimeOriginal=" "-IPTC:DateCreated=" "-IPTC:TimeCreated=" "-XMP:DateCreated=" "$cfile"
#
# cfile="5xmp_createdate.JPG"
# echo "Preparing file $cfile ..."
# cp "$@" "$cfile"
# exiftool -P -overwrite_original "-FileModifyDate=2007:07:07 07:07:07" "-EXIF:DateTimeOriginal=" "-IPTC:DateCreated=" "-IPTC:TimeCreated=" "-XMP:DateCreated=" "-EXIF:CreateDate=" "$cfile"
#
# cfile="6iptc_digitalcreationdate.JPG"
# echo "Preparing file $cfile ..."
# cp "$@" "$cfile"
# exiftool -P -overwrite_original "-FileModifyDate=2007:07:07 07:07:07" "-EXIF:DateTimeOriginal=" "-IPTC:DateCreated=" "-IPTC:TimeCreated=" "-XMP:DateCreated=" "-EXIF:CreateDate=" "-XMP:CreateDate=" "$cfile"
#
# cfile="7filemodifydate.JPG"
# echo "Preparing file $cfile ..."
# cp "$@" "$cfile"
# exiftool -P -overwrite_original "-FileModifyDate=2007:07:07 07:07:07" "-EXIF:DateTimeOriginal=" "-IPTC:DateCreated=" "-IPTC:TimeCreated=" "-XMP:DateCreated=" "-EXIF:CreateDate=" "-XMP:CreateDate=" "-IPTC:DigitalCreationDate=" "-IPTC:DigitalCreationTime=" "$cfile"
