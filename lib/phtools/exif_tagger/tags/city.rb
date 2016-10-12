#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag'

module ExifTagger
  module Tag
    # MWG:City, String[0,32]
    #   = IPTC:City XMP-photoshop:City XMP-iptcExt:LocationShownCity
    # Read sequence from mini_exiftool hash: City -> LocationShownCity

    class City < Tag
      EXIFTOOL_TAGS = %w(City LocationShownCity).freeze

      private

      def generate_write_script_lines
        @write_script_lines << %(-MWG:City=#{@value})
      end
    end
  end
end
