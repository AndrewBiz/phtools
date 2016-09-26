#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative 'tag'

module ExifTagger
  module Tag
    # MWG:Keywords, string[0,64]+, List of Strings
    #   = IPTC:Keywords, XMP-dc:Subject
    class Keywords < Tag
      MAX_BYTESIZE = 64
      EXIFTOOL_TAGS = %w(Keywords Subject)

      def initialize(value_raw = [])
        super(Array(value_raw).flatten.map { |i| i.to_s })
      end

      def check_for_warnings(original_values: {})
        @warnings = []
        @warnings.freeze
      end

      private

      def validate
        @value.each do |v|
          bsize = v.bytesize
          if bsize > MAX_BYTESIZE
            @errors << %{#{tag_name}: '#{v}' } +
                       %{is #{bsize - MAX_BYTESIZE} bytes longer than allowed #{MAX_BYTESIZE}}
            @value_invalid << v
          end
        end
        @value = @value - @value_invalid
      end

      def generate_write_script_lines
        @write_script_lines = []
        unless @value.empty?
          @value.each do |o|
            @write_script_lines << %Q(-MWG:Keywords-=#{o})
            @write_script_lines << %Q(-MWG:Keywords+=#{o})
          end
        end
      end
    end
  end
end
