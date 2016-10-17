#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_string'

module ExifTagger
  module Tag
    # ImageUniqueID, String
    class ImageUniqueId < TagString
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(ImageUniqueID)

      # def initialize(value_raw = [])
      #   super(value_raw.to_s)
      # end

      def check_for_warnings(original_values: {})
        @warnings = []
        v = original_values[EXIFTOOL_TAGS[0]]
        if v =~ /(\d{8}-\S+)/
          @warnings << "#{tag_name} has original correct value: '#{v}'"
        end
        @warnings.freeze
      end

      private

      def generate_write_script_lines
        @write_script_lines = []
        unless @value.empty?
          @write_script_lines << %Q(-ImageUniqueID=#{@value})
        end
      end
    end
  end
end
