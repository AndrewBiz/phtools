#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag'

module ExifTagger
  module Tag
    # MWG:Creator, string[0,32]+, List of strings
    #   = EXIF:Artist, IPTC:By-line, XMP-dc:Creator
    class Creator < Tag
      EXIFTOOL_TAGS = %w(Artist By-line Creator)

      def initialize(value_raw = [])
        super(Array(value_raw).flatten.map { |i| i.to_s })
      end

      private

      def validate
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
        @write_script_lines = []
        unless @value.empty?
          @value.each do |o|
            @write_script_lines << %Q(-MWG:Creator-=#{o})
            @write_script_lines << %Q(-MWG:Creator+=#{o})
          end
        end
      end
    end
  end
end
