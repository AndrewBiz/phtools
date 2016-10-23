#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_string'

module ExifTagger
  module Tag
    # MWG:Location, String[0,32]
    #   IPTC:Sub-location, XMP-iptcCore:Location, XMP-iptcExt:LocationShownSublocation
    class Location < TagString
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(Sub-location Location LocationShownSublocation).freeze

      private

      def generate_write_script_lines
        @write_script_lines << %(-MWG:Location=#{@value})
      end
    end
  end
end
