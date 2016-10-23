#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_string'

module ExifTagger
  module Tag
    # MWG:State, String[0,32]
    #   IPTC:Province-State, XMP-photoshop:State, XMP-iptcExt:LocationShownProvinceState
    class State < TagString
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(Province-State State LocationShownProvinceState).freeze

      private

      def generate_write_script_lines
        @write_script_lines << %(-MWG:State=#{@value})
      end
    end
  end
end
