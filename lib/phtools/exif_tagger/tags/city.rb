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
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(City LocationShownCity).freeze

      def initialize(value_raw = '')
        if value_raw.class == MiniExiftool
          self.class::EXIFTOOL_TAGS.each do |tag|
            v = value_raw[tag]
            unless v.nil?
              super(v.to_s)
              break
            end
          end
        else
          super(value_raw.to_s)
        end
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
        return if @value.empty?
        @write_script_lines << %(-MWG:City=#{@value})
      end
    end
  end
end
