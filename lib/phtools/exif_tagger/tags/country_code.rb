#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_string'

module ExifTagger
  module Tag
    # XMP-iptcExt:LocationShownCountryCode, String
    class CountryCode < TagString
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(LocationShownCountryCode).freeze

      private

      def generate_write_script_lines
        @write_script_lines << %(-XMP-iptcExt:LocationShownCountryCode=#{@value})
      end
    end
  end
end
