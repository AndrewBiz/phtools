#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_date'

module ExifTagger
  module Tag
    # -MWG:DateTimeOriginal:
    #    EXIF:DateTimeOriginal, (EXIF:SubSecTimeOriginal), IPTC:DateCreated + IPTC:TimeCreated,    XMP-photoshop:DateCreated
    # creation date of the intellectual content being shown
    class DateTimeOriginal < TagDate
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(DateTimeOriginal SubSecTimeOriginal DateCreated TimeCreated).freeze

      private

      def get_from_raw
        return @raw_values['DateTimeOriginal'] unless Tag.empty?(@raw_values['DateTimeOriginal'])
        unless Tag.empty?(@raw_values['DateCreated'])
          return @raw_values['DateCreated'] if @raw_values['DateCreated'].is_a?(DateTime)
          return make_date_from(@raw_values['DateCreated'], @raw_values['TimeCreated']) if @raw_values['DateCreated'].is_a?(String)
        end
        EMPTY
      end

      def generate_write_script_lines
        @write_script_lines << if @value.is_a?(DateTime)
                                 %(-MWG:DateTimeOriginal=#{@value.strftime('%F %T')})
                               else
                                 %(-MWG:DateTimeOriginal=#{@value})
                               end
      end
    end
  end
end
