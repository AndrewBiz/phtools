# -- encoding: utf-8 --
#
# MiniExiftool
#
# This library is wrapper for the Exiftool command-line
# application (http://www.sno.phy.queensu.ca/~phil/exiftool/)
# written by Phil Harvey.
# Read and write access is done in a clean OO manner.
#
# Author: Jan Friedrich
# Copyright (c) 2007-2013 by Jan Friedrich
# Licensed under the GNU LESSER GENERAL PUBLIC LICENSE,
# Version 2.1, February 1999
#

require 'fileutils'
require 'json'
require 'pstore'
require 'rational'
require 'rbconfig'
require 'set'
require 'tempfile'
require 'time'
require 'nesty' # ANB

# Simple OO access to the Exiftool command-line application.
class MiniExiftool

  VERSION = '2.3.0'

  # Name of the Exiftool command-line application
  @@cmd = 'exiftool'

  # Hash of the standard options used when call MiniExiftool.new
  @@opts = { :numerical => false, :composite => true, :ignore_minor_errors => false,
   :replace_invalid_chars => false, :timestamps => Time }

  # Encoding of the filesystem (filenames in command line)
  @@fs_enc = Encoding.find('filesystem')

  def self.opts_accessor *attrs
    attrs.each do |a|
      define_method a do
        @opts[a]
      end
      define_method "#{a}=" do |val|
        @opts[a] = val
      end
    end
  end

  attr_reader :filename, :errors

  opts_accessor :numerical, :composite, :ignore_minor_errors,
    :replace_invalid_chars, :timestamps

  @@encoding_types = %w(exif iptc xmp png id3 pdf photoshop quicktime aiff mie vorbis)

  def self.encoding_opt enc_type
    (enc_type.to_s + '_encoding').to_sym
  end

  @@encoding_types.each do |enc_type|
    opts_accessor encoding_opt(enc_type)
  end

  # +opts+ support at the moment
  # * <code>:numerical</code> for numerical values, default is +false+
  # * <code>:composite</code> for including composite tags while loading,
  #   default is +true+
  # * <code>:ignore_minor_errors</code> ignore minor errors (See -m-option
  #   of the exiftool command-line application, default is +false+)
  # * <code>:coord_format</code> set format for GPS coordinates (See
  #   -c-option of the exiftool command-line application, default is +nil+
  #   that means exiftool standard)
  # * <code>:replace_invalid_chars</code> replace string for invalid
  #   UTF-8 characters or +false+ if no replacing should be done,
  #   default is +false+
  # * <code>:timestamps</code> generating DateTime objects instead of
  #   Time objects if set to <code>DateTime</code>, default is +Time+
  #
  #   <b>ATTENTION:</b> Time objects are created using <code>Time.local</code>
  #   therefore they use <em>your local timezone</em>, DateTime objects instead
  #   are created <em>without timezone</em>!
  # * <code>:exif_encoding</code>, <code>:iptc_encoding</code>,
  #   <code>:xmp_encoding</code>, <code>:png_encoding</code>,
  #   <code>:id3_encoding</code>, <code>:pdf_encoding</code>,
  #   <code>:photoshop_encoding</code>, <code>:quicktime_encoding</code>,
  #   <code>:aiff_encoding</code>, <code>:mie_encoding</code>,
  #   <code>:vorbis_encoding</code> to set this specific encoding (see
  #   -charset option of the exiftool command-line application, default is
  #   +nil+: no encoding specified)
  def initialize filename=nil, opts={}
    @opts = @@opts.merge opts
    if @opts[:convert_encoding]
      warn 'Option :convert_encoding is not longer supported!'
      warn 'Please use the String#encod* methods.'
    end
    @values = TagHash.new
    @changed_values = TagHash.new
    @errors = TagHash.new
    load filename unless filename.nil?
  end

  def initialize_from_hash hash # :nodoc:
    set_values hash
    set_opts_by_heuristic
    self
  end

  def initialize_from_json json # :nodoc:
    @output = json
    @errors.clear
    parse_output
    self
  end

  # Load the tags of filename.
  def load filename
    MiniExiftool.setup
    unless filename && File.exist?(filename)
      raise MiniExiftool::Error.new("File '#{filename}' does not exist.")
    end
    if File.directory?(filename)
      raise MiniExiftool::Error.new("'#{filename}' is a directory.")
    end
    @filename = filename
    @values.clear
    @changed_values.clear
    params = '-j '
    params << (@opts[:numerical] ? '-n ' : '')
    params << (@opts[:composite] ? '' : '-e ')
    params << (@opts[:coord_format] ? "-c \"#{@opts[:coord_format]}\"" : '')
    @@encoding_types.each do |enc_type|
      if enc_val = @opts[MiniExiftool.encoding_opt(enc_type)]
        params << "-charset #{enc_type}=#{enc_val} "
      end
    end
    if run(cmd_gen(params, @filename))
      parse_output
    else
      raise MiniExiftool::Error.new(@error_text)
    end
    self
  end

  # Reload the tags of an already read file.
  def reload
    load @filename
  end

  # Returns the value of a tag.
  def [] tag
    @changed_values[tag] || @values[tag]
  end

  # Set the value of a tag.
  def []= tag, val
    @changed_values[tag] = val
  end

  # Returns true if any tag value is changed or if the value of a
  # given tag is changed.
  def changed? tag=false
    if tag
      @changed_values.include? tag
    else
      !@changed_values.empty?
    end
  end

  # Revert all changes or the change of a given tag.
  def revert tag=nil
    if tag
      val = @changed_values.delete(tag)
      res = val != nil
    else
      res = @changed_values.size > 0
      @changed_values.clear
    end
    res
  end

  # Returns an array of the tags (original tag names) of the read file.
  def tags
    @values.keys.map { |key| MiniExiftool.original_tag(key) }
  end

  # Returns an array of all changed tags.
  def changed_tags
    @changed_values.keys.map { |key| MiniExiftool.original_tag(key) }
  end

  # Save the changes to the file.
  def save
    MiniExiftool.setup
    return false if @changed_values.empty?
    @errors.clear
    temp_file = Tempfile.new('mini_exiftool')
    temp_file.close
    temp_filename = temp_file.path
    FileUtils.cp filename.encode(@@fs_enc), temp_filename
    all_ok = true
    @changed_values.each do |tag, val|
      original_tag = MiniExiftool.original_tag(tag)
      arr_val = val.kind_of?(Array) ? val : [val]
      arr_val.map! {|e| convert_before_save(e)}
      params = '-q -P -overwrite_original '
      params << (arr_val.detect {|x| x.kind_of?(Numeric)} ? '-n ' : '')
      params << (@opts[:ignore_minor_errors] ? '-m ' : '')
      arr_val.each do |v|
        params << %Q(-#{original_tag}=#{escape(v)} )
      end
      result = run(cmd_gen(params, temp_filename))
      unless result
        all_ok = false
        @errors[tag] = @error_text.gsub(/Nothing to do.\n\z/, '').chomp
      end
    end
    if all_ok
      FileUtils.cp temp_filename, filename.encode(@@fs_enc)
      reload
    end
    temp_file.delete
    all_ok
  end

  def save!
    unless save
      err = []
      @errors.each do |key, value|
        err << "(#{key}) #{value}"
      end
      raise MiniExiftool::Error.new("MiniExiftool couldn't save. The following errors occurred: #{err.empty? ? "None" : err.join(", ")}")
    end
  end

  # Returns a hash of the original loaded values of the MiniExiftool
  # instance.
  def to_hash
    result = {}
    @values.each do |k,v|
      result[MiniExiftool.original_tag(k)] = v
    end
    result
  end

  # Returns a YAML representation of the original loaded values of the
  # MiniExiftool instance.
  def to_yaml
    to_hash.to_yaml
  end

  # Create a MiniExiftool instance from a hash. Default value
  # conversions will be applied if neccesary.
  def self.from_hash hash, opts={}
    instance = MiniExiftool.new nil, opts
    instance.initialize_from_hash hash
    instance
  end

  # Create a MiniExiftool instance from JSON data. Default value
  # conversions will be applied if neccesary.
  def self.from_json json, opts={}
    instance = MiniExiftool.new nil, opts
    instance.initialize_from_json json
    instance
  end

  # Create a MiniExiftool instance from YAML data created with
  # MiniExiftool#to_yaml
  def self.from_yaml yaml, opts={}
    MiniExiftool.from_hash YAML.load(yaml), opts
  end

  # Returns the command name of the called Exiftool application.
  def self.command
    @@cmd
  end

  # Setting the command name of the called Exiftool application.
  def self.command= cmd
    @@cmd = cmd
  end

  # Returns the options hash.
  def self.opts
    @@opts
  end

  # Returns a set of all known tags of Exiftool.
  def self.all_tags
    unless defined? @@all_tags
      @@all_tags = pstore_get :all_tags
    end
    @@all_tags
  end

  # Returns a set of all possible writable tags of Exiftool.
  def self.writable_tags
    unless defined? @@writable_tags
      @@writable_tags = pstore_get :writable_tags
    end
    @@writable_tags
  end

  # Returns the original Exiftool name of the given tag
  def self.original_tag tag
    unless defined? @@all_tags_map
      @@all_tags_map = pstore_get :all_tags_map
    end
    @@all_tags_map[tag]
  end

  # Returns the version of the Exiftool command-line application.
  def self.exiftool_version
    output = `#{MiniExiftool.command} -ver 2>&1`
    unless $?.exitstatus == 0
      raise MiniExiftool::Error.new("Command '#{MiniExiftool.command}' not found")
    end
    output.chomp!
  end

  def self.unify tag
    tag.to_s.gsub(/[-_]/,'').downcase
  end

  # Exception class
  class MiniExiftool::Error < Nesty::NestedStandardError; end # ANB

  ############################################################################
  private
  ############################################################################

  @@setup_done = false
  def self.setup
    return if @@setup_done
    @@error_file = Tempfile.new 'errors'
    @@error_file.close
    @@setup_done = true
  end

  def cmd_gen arg_str='', filename
    [@@cmd, arg_str.encode('UTF-8'), escape(filename.encode(@@fs_enc))].map {|s| s.force_encoding('UTF-8')}.join(' ')
  end

  def run cmd
    if $DEBUG
      $stderr.puts cmd
    end
    @output = `#{cmd} 2>#{@@error_file.path}`
    @status = $?
    unless @status.exitstatus == 0
      @error_text = File.readlines(@@error_file.path).join
      @error_text.force_encoding('UTF-8')
      return false
    else
      @error_text = ''
      return true
    end
  end

  def convert_before_save val
    case val
    when Time
      val = val.strftime('%Y:%m:%d %H:%M:%S')
    end
    val
  end

  def method_missing symbol, *args
    tag_name = symbol.id2name
    if tag_name.sub!(/=$/, '')
      self[tag_name] = args.first
    else
      self[tag_name]
    end
  end

  def parse_output
    adapt_encoding
    set_values JSON.parse(@output).first
  end

  def adapt_encoding
    @output.force_encoding('UTF-8')
    if @opts[:replace_invalid_chars] && !@output.valid_encoding?
      @output.encode!('UTF-16le', invalid: :replace, replace: @opts[:replace_invalid_chars]).encode!('UTF-8')
    end
  end

  def convert_after_load tag, value
    return value unless value.kind_of?(String)
    return value unless value.valid_encoding?
    case value
    when /^\d{4}:\d\d:\d\d \d\d:\d\d:\d\d/
      s = value.sub(/^(\d+):(\d+):/, '\1-\2-')
      begin
        if @opts[:timestamps] == Time
          value = Time.parse(s)
        elsif @opts[:timestamps] == DateTime
          value = DateTime.parse(s)
        else
          raise MiniExiftool::Error.new("Value #{@opts[:timestamps]} not allowed for option timestamps.")
        end
      rescue ArgumentError
        value = false
      end
    when /^\+\d+\.\d+$/
      value = value.to_f
    when /^0+[1-9]+$/
      # nothing => String
    when /^-?\d+$/
      value = value.to_i
    when %r(^(\d+)/(\d+)$)
      value = Rational($1.to_i, $2.to_i)
    when /^[\d ]+$/
      # nothing => String
    end
    value
  end

  def set_values hash
    hash.each_pair do |tag,val|
      @values[tag] = convert_after_load(tag, val)
    end
    # Remove filename specific tags use attr_reader
    # MiniExiftool#filename instead
    # Cause: value of tag filename and attribute
    # filename have different content, the latter
    # holds the filename with full path (like the
    # sourcefile tag) and the former the basename
    # of the filename also there is no official
    # "original tag name" for sourcefile
    %w(directory filename sourcefile).each do |t|
      @values.delete(t)
    end
  end

  def set_opts_by_heuristic
    @opts[:composite] = tags.include?('ImageSize')
    @opts[:numerical] = self.file_size.kind_of?(Integer)
    @opts[:timestamps] = self.FileModifyDate.kind_of?(DateTime) ? DateTime : Time
  end

  def self.pstore_get attribute
    load_or_create_pstore unless defined? @@pstore
    result = nil
    @@pstore.transaction(true) do |ps|
      result = ps[attribute]
    end
    result
  end

  @@running_on_windows = /mswin|mingw|cygwin/ === RbConfig::CONFIG['host_os']

  def self.load_or_create_pstore
    # This will hopefully work on *NIX and Windows systems
    home = ENV['HOME'] || ENV['HOMEDRIVE'] + ENV['HOMEPATH'] || ENV['USERPROFILE']
    subdir = @@running_on_windows ? '_mini_exiftool' : '.mini_exiftool'
    FileUtils.mkdir_p(File.join(home, subdir))
    pstore_filename = File.join(home, subdir, 'exiftool_tags_' << exiftool_version.gsub('.', '_') << '.pstore')
    @@pstore = PStore.new pstore_filename
    if !File.exist?(pstore_filename) || File.size(pstore_filename) == 0
      @@pstore.transaction do |ps|
        ps[:all_tags] = all_tags = determine_tags('list')
        ps[:writable_tags] = determine_tags('listw')
        map = {}
        all_tags.each { |k| map[unify(k)] = k }
        ps[:all_tags_map] = map
      end
    end
  end

  def self.determine_tags arg
    output = `#{@@cmd} -#{arg}`
    lines = output.split(/\n/)
    tags = Set.new
    lines.each do |line|
      next unless line =~ /^\s/
      tags |= line.chomp.split
    end
    tags
  end

  if @@running_on_windows
    def escape val
      '"' << val.to_s.gsub(/([\\"])/, "\\\\\\1") << '"'
    end
  else
    def escape val
      '"' << val.to_s.gsub(/([\\"$])/, "\\\\\\1") << '"'
    end
  end

  # Hash with indifferent access:
  # DateTimeOriginal == datetimeoriginal == date_time_original
  class TagHash < Hash # :nodoc:
    def[] k
      super(unify(k))
    end
    def []= k, v
      super(unify(k), v)
    end
    def delete k
      super(unify(k))
    end

    def unify tag
      MiniExiftool.unify tag
    end
  end
end

# ANB - dump of real @values:
# exiftoolversion=9.41
# filesize=128 kB
# filemodifydate=2014-04-02T23:00:50+04:00
# fileaccessdate=2014-04-02T23:00:51+04:00
# fileinodechangedate=2014-04-02T23:00:50+04:00
# filepermissions=rw-r--r--
# filetype=JPEG
# mimetype=image/jpeg
# jfifversion=1.01
# exifbyteorder=Little-endian (Intel, II)
# imagedescription=
# make=SONY
# model=SLT-A65V
# xresolution=350
# yresolution=350
# resolutionunit=inches
# software=SLT-A65V v1.05
# modifydate=2014-04-02T20:50:32+00:00
# artist=Andrey Bizyaev (photographer); Andrey Bizyaev (camera owner)
# ycbcrpositioning=Co-sited
# copyright=2013 (c) Andrey Bizyaev. All Rights Reserved.
# exposuretime=1/100
# fnumber=5.6
# exposureprogram=Program AE
# iso=160
# sensitivitytype=Recommended Exposure Index
# recommendedexposureindex=160
# exifversion=230
# datetimeoriginal=2013-01-03T15:39:08+00:00
# createdate=2013-01-03T15:39:08+00:00
# componentsconfiguration=Y, Cb, Cr, -
# compressedbitsperpixel=2
# brightnessvalue=6.3375
# exposurecompensation=0
# maxaperturevalue=5.6
# meteringmode=Multi-segment
# lightsource=Unknown
# flash=Off, Did not fire
# focallength=55.0 mm
# quality=Fine
# flashexposurecomp=0
# teleconverter=None
# whitebalancefinetune=0
# rating=0
# brightness=0
# longexposurenoisereduction=On (unused)
# highisonoisereduction=Normal
# hdr=Off; Uncorrected image
# multiframenoisereduction=Off
# pictureeffect=Off
# softskineffect=Off
# vignettingcorrection=Auto
# lateralchromaticaberration=Auto
# distortioncorrection=Off
# wbshiftabgm=0 0
# faceinfooffset=94
# sonydatetime=2013-01-03T15:39:08+00:00
# sonyimagewidth=6000
# facesdetected=0
# faceinfolength=37
# metaversion=DC7303320222000
# maxaperture=5.3
# minaperture=33
# flashstatus=Built-in Flash present
# imagecount=8330
# lensmount=A-Mount
# lensformat=APS-C
# sequenceimagenumber=1
# sequencefilenumber=1
# releasemode2=Normal
# shotnumbersincepowerup=2
# sequencelength=1 shot
# cameraorientation=Horizontal (normal)
# quality2=JPEG
# sonyimageheight=4000
# modelreleaseyear=2011
# batterylevel=18%
# afpointsselected=(all)
# fileformat=ARW 2.3
# sonymodelid=SLT-A65 / SLT-A65V
# creativestyle=Standard
# colortemperature=Auto
# colorcompensationfilter=0
# scenemode=Auto
# zonematching=ISO Setting Used
# dynamicrangeoptimizer=Auto
# imagestabilization=On
# lenstype=Sony DT 16-105mm F3.5-5.6 (SAL16105)
# colormode=Standard
# lensspec=DT 16-105mm F3.5-5.6
# fullimagesize=6000x4000
# previewimagesize=1616x1080
# flashlevel=Normal
# releasemode=Normal
# sequencenumber=Single
# antiblur=On (Shooting)
# intelligentauto=On
# whitebalance=Auto
# usercomment=
# flashpixversion=100
# colorspace=sRGB
# exifimagewidth=800
# exifimageheight=534
# interopindex=R98 - DCF basic file (sRGB)
# interopversion=100
# relatedimagewidth=6000
# relatedimageheight=4000
# filesource=Digital Camera
# scenetype=Directly photographed
# customrendered=Normal
# exposuremode=Auto
# focallengthin35mmformat=82 mm
# scenecapturetype=Standard
# contrast=Normal
# saturation=Normal
# sharpness=Normal
# imageuniqueid=20140402-205030-0001
# lensinfo=16-105mm f/3.5-5.6
# lensmodel=DT 16-105mm F3.5-5.6
# gpsversionid=2.3.0.0
# gpslatituderef=North
# gpslongituderef=East
# gpsaltituderef=Above Sea Level
# gpstimestamp=11:39:09.588
# gpsstatus=Measurement Active
# gpsmeasuremode=3-Dimensional Measurement
# gpsdop=2.0026
# gpsspeedref=km/h
# gpsspeed=1.097
# gpstrackref=True North
# gpstrack=357.15
# gpsmapdatum=WGS-84
# gpsdatestamp=2013:01:03
# gpsdifferential=No Correction
# printimversion=300
# compression=JPEG (old-style)
# orientation=Horizontal (normal)
# thumbnailoffset=21840
# thumbnaillength=5859
# xmptoolkit=Image::ExifTool 9.41
# location=Дворцовая пл.
# locationshowncity=Санкт-Петербург
# locationshowncountrycode=RU
# locationshowncountryname=Russia
# locationshownprovincestate=Санкт-Петербург
# locationshownsublocation=Дворцовая пл.
# locationshownworldregion=Europe
# creator=["Andrey Bizyaev (photographer)", "Andrey Bizyaev (camera owner)"]
# rights=2013 (c) Andrey Bizyaev. All Rights Reserved.
# subject=["before-what-travel", "before-who-Andrew", "before-where-Baltic", "before-when-day", "before-why-vacation", "before-how-fine", "before-method-digicam"]
# collectionname=S-Peterburg Travel
# collectionuri=anblab.net
# country=Russia
# state=Санкт-Петербург
# iptcdigest=1569c0bffab4b64cb1107134254cf97d
# currentiptcdigest=7be9172b29568717f9bc0976c93ba53d
# codedcharacterset=UTF8
# enveloperecordversion=4
# keywords=["before-what-travel", "before-who-Andrew", "before-where-Baltic", "before-when-day", "before-why-vacation", "before-how-fine", "before-method-digicam"]
# byline=["Andrey Bizyaev (photographer)", "Andrey Bizyaev (camera owner)"]
# city=Санкт-Петербург
# sublocation=Дворцовая пл.
# provincestate=Санкт-Петербург
# countryprimarylocationname=Russia
# copyrightnotice=2013 (c) Andrey Bizyaev. All Rights Reserved.
# applicationrecordversion=4
# imagewidth=800
# imageheight=534
# encodingprocess=Baseline DCT, Huffman coding
# bitspersample=8
# colorcomponents=3
# ycbcrsubsampling=YCbCr4:4:4 (1 1)
# aperture=5.6
# gpsaltitude=0.5 m Above Sea Level
# gpsdatetime=2013-01-03T11:39:09+00:00
# gpslatitude=60 deg 0' 0.00" N
# gpslongitude=25 deg 0' 0.00" E
# gpsposition=60 deg 0' 0.00" N, 25 deg 0' 0.00" E
# imagesize=800x534
# lensid=Sony DT 16-105mm F3.5-5.6 (SAL16105)
# scalefactor35efl=1.5
# shutterspeed=1/100
# thumbnailimage=(Binary data 5859 bytes)
# circleofconfusion=0.020 mm
# fov=24.8 deg
# focallength35efl=55.0 mm (35 mm equivalent: 82.0 mm)
# hyperfocaldistance=26.80 m
# lightvalue=10.9
