#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative 'tag'

module ExifTagger
  module Tag
    # ImageUniqueID, String
    class ImageUniqueId < Tag
      MAX_BYTESIZE = 32 # no limit in EXIF spec
      EXIFTOOL_TAGS = %w(ImageUniqueID)

      def initialize(value_raw = [])
        super(value_raw.to_s)
      end

      def check_for_warnings(original_values: {})
        @warnings = []
        v = original_values[EXIFTOOL_TAGS[0]]
        if v =~ /(\d{8}-\S+)/
          @warnings << "#{tag_name} has original correct value: '#{v}'"
        end
        @warnings.freeze
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
          @write_script_lines << %Q(-ImageUniqueID=#{@value})
        end
      end
    end
  end
end
