#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative 'tag'

module ExifTagger
  module Tag
    # NMG:Copyright, string[0,128]
    #   = EXIF:Copyright IPTC:CopyrightNotice XMP-dc:Rights
    class Copyright < Tag
      MAX_BYTESIZE = 128
      EXIFTOOL_TAGS = %w(Copyright CopyrightNotice Rights)

      def initialize(value_raw = '')
        super(value_raw.to_s)
      end

      private

      def validate
        bsize = @value.bytesize
        if bsize > MAX_BYTESIZE
          @errors << %{#{tag_name}: '#{@value}' } +
                     %{is #{bsize - MAX_BYTESIZE} bytes longer than allowed #{MAX_BYTESIZE}}
          @value_invalid << @value
          @value = ''
        end
      end

      def generate_write_script_lines
        @write_script_lines = []
        unless @value.empty?
          @write_script_lines << %Q(-MWG:Copyright=#{@value})
        end
      end
    end
  end
end
