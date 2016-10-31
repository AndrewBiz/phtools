#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag'
require 'date'

module ExifTagger
  module Tag
    class TagDate < Tag
      private

      def get_from_raw
        @raw_values.each_value do |value|
          return value unless Tag.empty?(value)
        end
        EMPTY
      end

      def make_date_from(tag_date = '', tag_time = '')
        dcdt = %(#{tag_date} #{tag_time})
        DateTime.parse(dcdt.sub(/^(\d+):(\d+):/, '\1-\2-'))
      rescue ArgumentError
        EMPTY
      end

      def validate_type
        if @value.is_a?(String)
          validate_string_size(@value)

        elsif @value.is_a?(DateTime)

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
