#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative 'tag_date'

module ExifTagger
  module Tag
    # -MWG:CreateDate:
    #    EXIF:CreateDate
    #    EXIF:SubSecTimeDigitized
    #    IPTC:DigitalCreationDate
    #    IPTC:DigitalCreationTime
    #    XMP-xmp:CreateDate
    # creation date of the digital representation
    class CreateDate < TagDate
      EXIFTOOL_TAGS = %w(CreateDate SubSecTimeDigitized DigitalCreationDate DigitalCreationTime)

      private

      def generate_write_script_lines
        @write_script_lines = []
        case
        when @value.kind_of?(String) && !@value.empty?
          @write_script_lines << %Q(-MWG:CreateDate=#{@value})
        when @value.kind_of?(DateTime) || @value.kind_of?(Time)
          @write_script_lines << %Q(-MWG:CreateDate=#{@value.strftime('%F %T')})
        end
      end
    end
  end
end
