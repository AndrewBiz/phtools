#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag'

module ExifTagger
  module Tag
    # -XMP-iptcExt:LocationShownWorldRegion, String
    class WorldRegion < Tag
      TYPE = :string
      MAX_BYTESIZE = 64 # No limit in XMP spec
      EXIFTOOL_TAGS = %w(LocationShownWorldRegion)

      def initialize(value_raw = [])
        super(value_raw.to_s)
      end

      private

      def generate_write_script_lines
        @write_script_lines = []
        unless @value.empty?
          @write_script_lines << %Q(-XMP-iptcExt:LocationShownWorldRegion=#{@value})
        end
      end
    end
  end
end
