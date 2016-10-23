#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_string'

module ExifTagger
  module Tag
    # ImageUniqueID, String
    class ImageUniqueId < TagString
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(ImageUniqueID).freeze

      private

      def validate_vs_previous
        @warnings = []
        return if @previous.nil?
        val = @previous.raw_values[EXIFTOOL_TAGS[0]]
        if val =~ /(\d{8}-\S+)/
          @warnings << "#{tag_name} has original value: '#{val}'"
        end
        @warnings.freeze
      end

      def generate_write_script_lines
        @write_script_lines << %(-ImageUniqueID=#{@value})
      end
    end
  end
end
