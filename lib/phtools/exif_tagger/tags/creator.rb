#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_array_of_strings'

module ExifTagger
  module Tag
    # MWG:Creator, string[0,32]+, List of strings
    #   EXIF:Artist, IPTC:By-line, XMP-dc:Creator
    # exiftool types:
    #   Artist = String "aaa; bbb"
    #   By-line = Array ["aaa", "bbb"] OR String "aaa"
    #   Creator = Array ["aaa", "bbb"] OR String "aaa"

    class Creator < TagArrayOfStrings
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(Artist By-line Creator).freeze

      private

      def generate_write_script_lines
        @value.each do |o|
          unless Tag.empty?(o)
            @write_script_lines << %(-MWG:Creator-=#{o})
            @write_script_lines << %(-MWG:Creator+=#{o})
          end
        end
      end
    end
  end
end
