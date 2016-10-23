#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_string'

module ExifTagger
  module Tag
    # MWG:Country, String[0,64]
    #  IPTC:Country-PrimaryLocationName, XMP-photoshop:Country, XMP-iptcExt:LocationShownCountryName
    class Country < TagString
      MAX_BYTESIZE = 64
      EXIFTOOL_TAGS = %w(Country-PrimaryLocationName Country LocationShownCountryName).freeze

      private

      def generate_write_script_lines
        @write_script_lines << %(-MWG:Country=#{@value})
      end
    end
  end
end
