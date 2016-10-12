#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag'
require 'date'

module ExifTagger
  module Tag
    class TagDate < Tag

      private

      def validate
        case
        when @value.kind_of?(String)
          bsize = @value.bytesize
          if bsize > MAX_BYTESIZE
            @errors << %(#{tag_name}: '#{@value}' ) +
              %(is #{bsize - MAX_BYTESIZE} bytes longer than allowed #{MAX_BYTESIZE})
            @value_invalid << @value
            @value = ''
          end
        when @value.kind_of?(DateTime)
          if @value == DateTime.new(0)
            @errors << %(#{tag_name}: '#{@value}' zero Date)
            @value_invalid << @value
            @value = ''
          end
        when @value.kind_of?(Time)
          if @value == Time.new(0)
            @errors << %(#{tag_name}: '#{@value}' zero Date)
            @value_invalid << @value
            @value = ''
          end
        else
          @errors << %(#{tag_name}: '#{@value}' is of wrong type (#{@value.class}))
          @value_invalid << @value
          @value = ''
        end
      end
    end
  end
end
