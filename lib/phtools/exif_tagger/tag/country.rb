#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative 'tag'

module ExifTagger
  module Tag
    # MWG:Country, String[0,64]
    #   = IPTC:Country-PrimaryLocationName XMP-photoshop:Country
    #       XMP-iptcExt:LocationShownCountryName
    class Country < Tag
      MAX_BYTESIZE = 64
      EXIFTOOL_TAGS = %w(Country-PrimaryLocationName Country LocationShownCountryName)

      def initialize(value_raw = '')
        super(value_raw.to_s)
      end

      private

      def validate
        bsize = @value.bytesize
        if bsize > MAX_BYTESIZE
          @errors << %(#{tag_name}: '#{@value}' ) +
                     %(is #{bsize - MAX_BYTESIZE} bytes longer than allowed #{MAX_BYTESIZE})
          @value_invalid << @value
          @value = ''
        end
      end

      def generate_write_script_lines
        @write_script_lines = []
        unless @value.empty?
          @write_script_lines << %Q(-MWG:Country=#{@value})
        end
      end
    end
  end
end
