#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_array_of_strings'

module ExifTagger
  module Tag
    # MWG:Creator, string[0,32]+, List of strings
    #   = EXIF:Artist, IPTC:By-line, XMP-dc:Creator
    class Creator < TagArrayOfStrings
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(Artist By-line Creator)

      private

      def validate
        @errors = []
        @value_invalid = []
        return if Tag.empty?(@value)

        @value.each do |v|
          bsize = v.bytesize
          if bsize > MAX_BYTESIZE
            @errors << %(#{tag_name}: '#{v}' ) +
                       %(is #{bsize - MAX_BYTESIZE} bytes longer than allowed #{MAX_BYTESIZE})
            @value_invalid << v
          end
        end
        @value = @value - @value_invalid
      end

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
