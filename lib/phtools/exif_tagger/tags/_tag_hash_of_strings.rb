#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag'

module ExifTagger
  module Tag
    class TagHashOfStrings < Tag
      private

      def validate_type
        if @value.is_a?(Hash)
          @value.each_value do |val|
            validate_string_size(val)
          end
          unknown_keys = @value.keys - self.class::VALID_KEYS
          unknown_keys.each do |k|
            @errors << %(#{tag_name}: KEY '#{k}' is unknown)
          end
          missed_keys = self.class::VALID_KEYS - @value.keys
          missed_keys.each do |k|
            @errors << %(#{tag_name}: KEY '#{k}' is missed)
          end
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
