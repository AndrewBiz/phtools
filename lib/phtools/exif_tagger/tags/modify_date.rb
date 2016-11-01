#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_date'

module ExifTagger
  module Tag
    # -EXIF:ModifyDate=now
    class ModifyDate < TagDate
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(ModifyDate).freeze

      private

      def generate_write_script_lines
        @write_script_lines << if @value.is_a?(DateTime)
                                 %(-EXIF:ModifyDate=#{@value.strftime('%F %T')})
                               else
                                 %(-EXIF:ModifyDate=#{@value})
                               end
      end
    end
  end
end
