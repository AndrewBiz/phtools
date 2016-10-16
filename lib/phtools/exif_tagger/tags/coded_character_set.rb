#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag'

module ExifTagger
  module Tag
    # -IPTC:CodedCharacterSet, string[0,32]!

    class CodedCharacterSet < Tag
      TYPE = :string
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(CodedCharacterSet).freeze

      private

      def generate_write_script_lines
        @write_script_lines << %(-IPTC:CodedCharacterSet=#{@value})
      end
    end
  end
end
