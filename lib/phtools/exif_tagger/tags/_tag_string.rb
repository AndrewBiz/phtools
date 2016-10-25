#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag'

module ExifTagger
  module Tag
    class TagString < Tag
      private

      def get_from_raw
        @raw_values.each_value do |value|
          return value unless Tag.empty?(value)
        end
        EMPTY
      end

      def validate_type
        if @value.is_a?(String)
          validate_string_size(@value)
        else
          @errors << %(#{tag_name}: '#{@value}' is a wrong type \(#{@value.class}\))
        end
        return if @errors.empty?
        @value_invalid << @value
        @value = EMPTY
      end
    end
  end
end
