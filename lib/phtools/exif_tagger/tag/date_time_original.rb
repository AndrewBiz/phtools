#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_date'

module ExifTagger
  module Tag
    # -MWG:DateTimeOriginal:
    #    EXIF:DateTimeOriginal
    #    EXIF:SubSecTimeOriginal
    #    IPTC:DateCreated
    #    IPTC:TimeCreated
    #    XMP-photoshop:DateCreated
    # creation date of the intellectual content being shown
    class DateTimeOriginal < TagDate
      EXIFTOOL_TAGS = %w(DateTimeOriginal SubSecTimeOriginal DateCreated TimeCreated)

      private

      def generate_write_script_lines
        @write_script_lines = []
        case
        when @value.kind_of?(String) && !@value.empty?
          @write_script_lines << %Q(-MWG:DateTimeOriginal=#{@value})
        when @value.kind_of?(DateTime) || @value.kind_of?(Time)
          @write_script_lines << %Q(-MWG:DateTimeOriginal=#{@value.strftime('%F %T')})
        end
      end
    end
  end
end
