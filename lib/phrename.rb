#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8

# (c) ANB Andrew Bizyaev

require 'date'
require 'mini_exiftool'
require 'phtools/runner'

module PhTools
  class Phrename < Runner
    def self.about
      'renames input files to phtools standard'
    end

    private

    def validate_options
      if @options_cli['--manual_date']
        @mode = :manual_rename
        @manual_date = PhFile.get_date_time(@options_cli['--manual_date'])
        fail PhTools::Error, '--manual_date value is incorrect' if @manual_date == PhFile::ZERO_DATE
        @author = @options_cli['--author'].upcase
        ok, msg = PhFile.validate_author(@author)
        fail PhTools::Error, msg unless ok
        @shift_seconds = @options_cli['--shift_time'].to_i

      elsif @options_cli['--author']
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
      info_msg = ''
      case @mode
      when :rename
        if phfile_out.basename_is_standard? && @user_tag_date.empty?
          # change only author, keeping date-time safe
          phfile_out.standardize!(author: @author)
          info_msg = "'#{phfile.basename + phfile.extname}' already standard name. Keeping date-time-in-name unchanged"
        else # full rename
          begin
            tags = MiniExiftool.new(phfile.filename,
                                    replace_invalid_chars: true,
                                    composite: true,
                                    timestamps: DateTime)
          rescue
            raise PhTools::Error, 'EXIF tags reading'
          end
          if @user_tag_date.empty?
            # searching for DateTime stamp value in the tags using priority:
            # EXIF:DateTimeOriginal -> IPTC:DateCreated + IPTC:TimeCreated -> XMP:DateCreated -> EXIF:CreateDate -> XMP:CreateDate -> IPTC:DigitalCreationDate + IPTC:DigitalCreationTime -> FileModifyDate
            if !tags.date_time_original.nil? && tags.date_time_original.is_a?(DateTime)
              # EXIF:DateTimeOriginal or IPTC:DateCreated + IPTC:TimeCreated
              dto = tags.date_time_original
              tag_used = 'DateTimeOriginal'

            elsif !tags.date_created.nil? && tags.date_created.is_a?(DateTime)
              # XMP:DateCreated
              dto = tags.date_created
              tag_used = 'DateCreated'

            elsif !tags.create_date.nil? && tags.create_date.is_a?(DateTime)
              # EXIF:CreateDate or XMP:CreateDate or! QuickTime:CreateDate
              dto = tags.create_date
              tag_used = 'CreateDate'

            elsif !tags.digital_creation_date.nil? &&
                  !tags.digital_creation_time.nil? &&
                  tags.digital_creation_date.is_a?(String) &&
                  tags.digital_creation_time.is_a?(String)
              # IPTC:DigitalCreationDate + IPTC:DigitalCreationTime
              dcdt = tags.digital_creation_date + ' ' + tags.digital_creation_time
              begin
                s = dcdt.sub(/^(\d+):(\d+):/, '\1-\2-')
                dto = DateTime.parse(s)
              rescue ArgumentError
                dto = PhFile::ZERO_DATE
              end
              tag_used = 'DigitalCreationDate + DigitalCreationTime'

            else
              # FileModifyDate
              dto = File.mtime(phfile.filename).to_datetime
              tag_used = 'FileModifyDate'
            end

          else
            # tag is set by the user
            fail PhTools::Error, "tag #{@user_tag_date} is not found in a file" unless tags[@user_tag_date]
            fail PhTools::Error, "tag #{@user_tag_date} is not a DateTime type" unless tags[@user_tag_date].is_a?(DateTime)
            dto = tags[@user_tag_date] || PhFile::ZERO_DATE
            tag_used = "#{@user_tag_date}"
          end
          phfile_out.standardize!(date_time: dto, author: @author)
          info_msg = "'#{phfile.basename + phfile.extname}' using tag '#{tag_used}' for date-time-in-the-name"
        end

      when :clean
        phfile_out.cleanse!

      when :shift_time
        fail PhTools::Error, 'non-standard file name' unless phfile_out.basename_is_standard?
        phfile_out.standardize!(date_time: phfile_out.date_time + @shift_seconds * (1.0 / 86_400))

      when :manual_rename
        if phfile_out.basename_is_standard?
          # keeping date-time safe
          info_msg = "'#{phfile.basename + phfile.extname}' already standard name. Keeping date-time-in-name unchanged"
        else # renaming
          phfile_out.standardize!(date_time: @manual_date, author: @author)
          @manual_date += @shift_seconds * (1.0 / 86_400)
        end
      end

      FileUtils.mv(phfile.filename, phfile_out.filename, verbose: PhTools.debug) unless phfile == phfile_out
      PhTools.puts_error info_msg unless info_msg.empty?
      phfile_out
    rescue StandardError => e
      raise PhTools::Error, 'file renaming - ' + e.message
    end
  end
end
