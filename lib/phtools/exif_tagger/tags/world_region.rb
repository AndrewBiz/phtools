#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_string'

module ExifTagger
  module Tag
    # XMP-iptcExt:LocationShownWorldRegion, String
    class WorldRegion < TagString
      MAX_BYTESIZE = 64 # No limit in XMP spec
      EXIFTOOL_TAGS = %w(LocationShownWorldRegion).freeze

      private

      def generate_write_script_lines
        @write_script_lines << %(-XMP:LocationShownWorldRegion=#{@value})
      end
    end
  end
end
