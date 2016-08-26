#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative 'error'
require 'date'
require 'fileutils'

# Foto tools
module PhTools
  # media type constants
  FILE_TYPE_IMAGE_NORMAL = %w{jpg jpeg tif tiff png}
  FILE_TYPE_IMAGE_RAW = %w{orf arw dng}
  FILE_TYPE_IMAGE = FILE_TYPE_IMAGE_NORMAL + FILE_TYPE_IMAGE_RAW
  FILE_TYPE_VIDEO = %w{avi mp4 mpg mts dv mov mkv m2t m2ts}
  FILE_TYPE_AUDIO = %w{wav}

  # phtools file name operations
  class FTFile
    include Comparable

    # filename constants
    NICKNAME_MIN_SIZE = 3
    NICKNAME_MAX_SIZE = 6
    NICKNAME_SIZE = 3 # should be in range of MIN and MAX
    ZERO_DATE = DateTime.new(0)

    def self.validate_file!(filename, file_type)
      fail PhTools::Error, 'does not exist'  unless
        filename && File.exist?(filename)
      fail PhTools::Error, 'not a file' if File.directory?(filename)
      fail PhTools::Error, 'no permission to write' unless
        File.writable_real?(filename)
      fail PhTools::Error, 'unsupported type' unless
        file_type.include?(File.extname(filename).slice(1..-1).downcase)
    end

    def self.validate_author(author)
      case
      when author.size != NICKNAME_SIZE
        return [false, "'#{author}' wrong author size, should be #{NICKNAME_SIZE} chars long"]
      when /[-_\s]/.match(author)
        return [false, "'#{author}' author should not contain spaces [_- ]"]
      when /[\d]/.match(author)
        return [false, "'#{author}' author should not contain digits"]
      when /[\W]/.match(author)
        return [false, "'#{author}' author should contain only ASCII chars"]
      end
      [true, '']
    end

    attr_reader :filename, :dirname, :extname, :basename, :basename_part,
                :basename_clean, :date_time, :author

    def initialize(filename)
      set_state(filename)
    end

    def to_s
      "#{@filename}"
    end

    def <=>(other)
      @filename <=> other.filename
    end

    def basename_standard(basename_clean: @basename_clean,
                          date_time: @date_time,
                          author: @author)
      %Q{#{date_time.strftime('%Y%m%d-%H%M%S')}_#{(author.upcase + "XXXXXX")[0, NICKNAME_SIZE]} #{basename_clean}}
    end

    def basename_is_standard?
      @basename == basename_standard
    end

    def standardize(dirname: @dirname, basename_clean: @basename_clean,
                    extname: @extname, date_time: @date_time,
                    author: @author)
      File.join(dirname,
                basename_standard(basename_clean: basename_clean,
                                  date_time: date_time,
                                  author: author) + extname)
    end

    def standardize!(dirname: @dirname, basename_clean: @basename_clean,
                     extname: @extname, date_time: @date_time,
                     author: @author)

      filename = standardize(dirname: dirname, basename_clean: basename_clean,
                             extname: extname, date_time: date_time,
                             author: author)
      set_state(filename)
      filename
    end

    def cleanse(dirname: @dirname, basename_clean: @basename_clean,
                extname: @extname)
      File.join(dirname, basename_clean + extname)
    end

    def cleanse!(dirname: @dirname, basename_clean: @basename_clean,
               extname: @extname)
      filename = cleanse(dirname: dirname, basename_clean: basename_clean,
                         extname: extname)
      set_state(filename)
      filename
    end

    def dirname=(dirname = @dirname)
      @dirname = dirname
      @filename = File.join(@dirname, @basename + @extname)
    end

    def date_time_ok?
      @date_time != ZERO_DATE
    end

    def date_time_to_time
      Time.new(@date_time.year, @date_time.month, @date_time.day,
               @date_time.hour, @date_time.min, @date_time.sec)
               # no use of @date_time.zone - assuming file's timezone always
               # equals to photografer's computer timezone
    end

    private

    def set_state(filename)
      @dirname = File.dirname(filename)
      @extname = File.extname(filename)
      @basename = File.basename(filename, @extname)
      @filename = File.join(@dirname, @basename + @extname)
      parse_basename
      @basename_clean = @basename_part[:clean]
      @date_time = reveal_date_time
      @author = @basename_part[:author] || ''
    end

    def reveal_date_time
      date = @basename_part[:date]
      time = @basename_part[:time]
      strptime_template = ''
      strptime_string = ''
      case date.size
      when 4 # expecting Year e.g.2001
        strptime_template += '%Y'
        strptime_string += date
      when 8 # expecting YYmmdd e.g.20010101
        strptime_template += '%Y%m%d'
        strptime_string += date
      end
      case time.size
      when 4 # expecting HHMM e.g. 1025
        strptime_template += '%H%M'
        strptime_string += time
      when 6 # expecting YHHMMSS e.g.102559
        strptime_template += '%H%M%S'
        strptime_string += time
      end

      return ZERO_DATE if strptime_string.empty?
      DateTime.strptime(strptime_string, strptime_template)

    rescue ArgumentError
      return ZERO_DATE
    end

    def parse_basename
      default = { prefix: '', clean: '', date: '',
                  time: '', author: '', id: '', flags: '' }
      case @basename
      # check YYYYmmdd-HHMMSS_AUT[ID]{FLAGS}cleanname
      when /^(?<prefix>(?<date>\d{8})-(?<time>\d{6})_(?<author>\w{#{NICKNAME_MIN_SIZE},#{NICKNAME_MAX_SIZE}})\[(?<id>.*)\]\{(?<flags>.*)\})(?<clean>.*)/
        @basename_part = default.merge(prefix: Regexp.last_match(:prefix),
                                       clean: Regexp.last_match(:clean),
                                       date: Regexp.last_match(:date),
                                       time: Regexp.last_match(:time),
                                       author: Regexp.last_match(:author),
                                       id: Regexp.last_match(:id),
                                       flags: Regexp.last_match(:flags))

      # check YYYYmmdd-HHMMSS_AUT[ID]cleanname
      when /^(?<prefix>(?<date>\d{8})-(?<time>\d{6})_(?<author>\w{#{NICKNAME_MIN_SIZE},#{NICKNAME_MAX_SIZE}})\[(?<id>.*)\])(?<clean>.*)/
        @basename_part = default.merge(prefix: Regexp.last_match(:prefix),
                                       clean: Regexp.last_match(:clean),
                                       date: Regexp.last_match(:date),
                                       time: Regexp.last_match(:time),
                                       author: Regexp.last_match(:author),
                                       id: Regexp.last_match(:id))
      # STANDARD template
      # check YYYYmmdd-HHMMSS_AUT cleanname
      when /^(?<prefix>(?<date>\d{8})-(?<time>\d{6})_(?<author>\w{#{NICKNAME_MIN_SIZE},#{NICKNAME_MAX_SIZE}})[-\s_])(?<clean>.*)/
        @basename_part = default.merge(prefix: Regexp.last_match(:prefix),
                                       clean: Regexp.last_match(:clean),
                                       date: Regexp.last_match(:date),
                                       time: Regexp.last_match(:time),
                                       author: Regexp.last_match(:author))
      # check if name = YYYYmmdd-HHMM_AAA_name
      when /^(?<prefix>(?<date>\d{8})-(?<time>\d{4})[-\s_](?<author>\w{#{NICKNAME_MIN_SIZE},#{NICKNAME_MAX_SIZE}})[-\s_])(?<clean>.*)/
        @basename_part = default.merge(prefix: Regexp.last_match(:prefix),
                                       clean: Regexp.last_match(:clean),
                                       date: Regexp.last_match(:date),
                                       time: Regexp.last_match(:time),
                                       author: Regexp.last_match(:author))
      # check if name = YYYYmmdd-HHMM_name
      when /^(?<prefix>(?<date>\d{8})-(?<time>\d{4})[-\s_])(?<clean>.*)/
        @basename_part = default.merge(prefix: Regexp.last_match(:prefix),
                                       clean: Regexp.last_match(:clean),
                                       date: Regexp.last_match(:date),
                                       time: Regexp.last_match(:time))
      # check if name = YYYYmmdd_name
      when /^(?<prefix>(?<date>\d{8})[-\s_])(?<clean>.*)/
        @basename_part = default.merge(prefix: Regexp.last_match(:prefix),
                                       clean: Regexp.last_match(:clean),
                                       date: Regexp.last_match(:date))
      # check if name = YYYY_name
      when /^(?<prefix>(?<date>\d{4})[-\s_])(?<clean>.*)/
        @basename_part = default.merge(prefix: Regexp.last_match(:prefix),
                                       clean: Regexp.last_match(:clean),
                                       date: Regexp.last_match(:date))
      else
        @basename_part = default.merge(clean: @basename)
      end
    end
  end
end
