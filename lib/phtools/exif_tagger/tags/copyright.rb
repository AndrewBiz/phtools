#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_string'

module ExifTagger
  module Tag
    # NMG:Copyright, string[0,128]
    #   EXIF:Copyright, IPTC:CopyrightNotice, XMP-dc:Rights
    class Copyright < TagString
      MAX_BYTESIZE = 128
      EXIFTOOL_TAGS = %w(Copyright CopyrightNotice Rights).freeze

      private

      def generate_write_script_lines
        @write_script_lines << %(-MWG:Copyright=#{@value})
      end
    end
  end
end
