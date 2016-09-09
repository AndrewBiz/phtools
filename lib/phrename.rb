#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'date'
require 'phtools/runner'
require 'phtools/mini_exiftool-2.3.0anb'

module PhTools
  class Phrename < Runner
    def self.about
      "renames input files to phtools standard"
    end

    private

    def validate_options
      if @options_cli['--author']
        @mode = :rename
        @author = @options_cli['--author'].upcase
        ok, msg = PhFile.validate_author(@author)
        fail PhTools::Error, msg unless ok
        @user_tag_date = @options_cli['--tag_date'] || ''
      elsif @options_cli['--clean']
        @mode = :clean
      elsif @options_cli['--shift_time']
        @mode = :shift_time
        @shift_seconds = @options_cli['--shift_time'].to_i
        fail PhTools::Error, '--shift_time value is not correct' if @shift_seconds.zero?
      end
    end

    def process_file(phfile)
      phfile_out = phfile.clone
      case @mode
      when :rename
        begin
          tag = MiniExiftool.new(phfile.filename, timestamps: DateTime)
        rescue
          raise PhTools::Error, 'EXIF tags reading'
        end
        if @user_tag_date.empty?
          dto = tag.date_time_original || tag.create_date || PhFile::ZERO_DATE
        else
          fail PhTools::Error, "tag #{@user_tag_date} is not found" unless tag[@user_tag_date]
          fail PhTools::Error, "tag #{@user_tag_date} is not a DateTime type" unless               tag[@user_tag_date].kind_of?(DateTime)
          dto = tag[@user_tag_date] || PhFile::ZERO_DATE
        end
        phfile_out.standardize!(date_time: dto, author: @author)

      when :clean
        phfile_out.cleanse!

      when :shift_time
        fail PhTools::Error, 'incorrect file name' unless phfile_out.basename_is_standard?
        phfile_out.standardize!(date_time: phfile_out.date_time + @shift_seconds*(1.0/86400))
      end

      FileUtils.mv(phfile.filename, phfile_out.filename) unless phfile == phfile_out
      phfile_out

    rescue => e
      raise PhTools::Error, 'file renaming - ' + e.message
    end
  end
end
