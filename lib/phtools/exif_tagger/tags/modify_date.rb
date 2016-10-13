#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_date'

module ExifTagger
  module Tag
    # -EXIF:ModifyDate=now
    class ModifyDate < TagDate
      TYPE = :date_time
      MAX_BYTESIZE = 32
      EXIFTOOL_TAGS = %w(ModifyDate)

      private

      def generate_write_script_lines
        @write_script_lines = []
        case
        when @value.kind_of?(String) && !@value.empty?
          @write_script_lines << %Q(-EXIF:ModifyDate=#{@value})
        when @value.kind_of?(DateTime) || @value.kind_of?(Time)
          @write_script_lines << %Q(-EXIF:ModifyDate=#{@value.strftime('%F %T')})
        end
      end
    end
  end
end
