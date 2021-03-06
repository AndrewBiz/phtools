#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_date'

module ExifTagger
  module Tag
    # -MWG:CreateDate:
    #   EXIF:CreateDate (EXIF:SubSecTimeDigitized),
    #   IPTC:DigitalCreationDate+IPTC:DigitalCreationTime,
    #   XMP-xmp:CreateDate
    # creation date of the digital representation
    class CreateDate < TagDate
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(CreateDate SubSecTimeDigitized DigitalCreationDate DigitalCreationTime).freeze

      private

      def get_from_raw
        return @raw_values['CreateDate'] unless Tag.empty?(@raw_values['CreateDate'])
        return make_date_from(@raw_values['DigitalCreationDate'], @raw_values['DigitalCreationTime']) unless Tag.empty?(@raw_values['DigitalCreationDate'])
        EMPTY
      end

      def generate_write_script_lines
        @write_script_lines << if @value.is_a?(DateTime)
                                 %(-MWG:CreateDate=#{@value.strftime('%F %T')})
                               else
                                 %(-MWG:CreateDate=#{@value})
                               end
      end
    end
  end
end
