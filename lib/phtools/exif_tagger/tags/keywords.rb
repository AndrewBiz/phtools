#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_array_of_strings'

module ExifTagger
  module Tag
    # MWG:Keywords, string[0,64]+, List of Strings
    #   IPTC:Keywords, XMP-dc:Subject
    # exiftool types:
    #   Keywords = Array ["aaa", "bbb"] OR String "aaa"
    #   Subject = Array ["aaa", "bbb"] OR String "aaa"

    class Keywords < TagArrayOfStrings
      MAX_BYTESIZE = 64
      EXIFTOOL_TAGS = %w(Keywords Subject).freeze

      private

      def validate_vs_previous
        @warnings = []
        @warnings.freeze
      end

      def generate_write_script_lines
        @value.each do |o|
          unless Tag.empty?(o)
            @write_script_lines << %(-MWG:Keywords-=#{o})
            @write_script_lines << %(-MWG:Keywords+=#{o})
          end
        end
      end
    end
  end
end
