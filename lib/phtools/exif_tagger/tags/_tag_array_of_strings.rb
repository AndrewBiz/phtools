#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag'

module ExifTagger
  module Tag
    class TagArrayOfStrings < Tag
      private

      def get_from_raw
        @raw_values.each_value do |v|
          v = v.split('; ') if v.is_a?(String)
          return v unless Tag.empty?(v)
        end
        EMPTY
      end

      def validate_type
        if @value.is_a?(Array)
          @value.each do |val|
            @value_invalid << val unless validate_string_size(val)
          end
          @value -= @value_invalid
        else
          @errors << %(#{tag_name}: '#{@value}' is a wrong type \(#{@value.class}\))
          @value_invalid << @value
          @value = EMPTY
        end
      end
    end
  end
end
