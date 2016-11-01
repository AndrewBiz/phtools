#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'active_support/core_ext'
require 'mini_exiftool'

module ExifTagger
  module Tag
    # Parent class for all tags
    class Tag
      include Comparable

      EMPTY = ''
      EMPTY_DATE = '0000-01-01 00:00:00'
      EXIFTOOL_TAGS = [].freeze
      MAX_BYTESIZE = 32

      attr_reader :errors, :value, :raw_values, :value_invalid, :warnings, :write_script_lines
      attr_reader :previous
      attr_accessor :info, :force_write

      def self.empty?(value)
        return true if value.nil?
        return value.empty? if value.is_a?(String)
        return value.join.empty? if value.is_a?(Array)
        return value.values.join.empty? if value.is_a?(Hash)
        false
      end

      def initialize(value = '', previous = nil)
        @raw_values = {}
        if value.class == MiniExiftool
          init_raw_values(value)
          @value = normalize(get_from_raw)
        else
          @value = normalize(value)
        end
        @previous = (previous.is_a?(self.class) ? previous : nil)
        @info = ''
        @force_write = false

        validate
        validate_vs_previous
        freeze_values
      end

      def tag_id
        self.class.to_s.demodulize.underscore.to_sym
      end

      def tag_name
        self.class.to_s.demodulize
      end

      def <=>(other)
        return tag_id <=> other.tag_id if other.respond_to?(:tag_id)
        tag_id <=> other.to_s.to_sym
      end

      def to_s
        return "#{tag_id} is EMPTY" if Tag.empty?(@value)
        "#{tag_id} = #{@value}"
      end

      def valid?
        @errors.empty?
      end

      # TODO: remove deprecated method
      def check_for_warnings(original_values: {})
        @warnings = []
        self.class::EXIFTOOL_TAGS.each do |tag|
          v = original_values[tag]
          unless v.nil?
            case
            when v.kind_of?(String)
              @warnings << "#{tag_name} has original value: #{tag}='#{v}'" unless v.empty?
            when v.kind_of?(Array)
              @warnings << "#{tag_name} has original value: #{tag}=#{v}" unless v.join.empty?
            else
              @warnings << "#{tag_name} has original value: #{tag}=#{v}"
            end
          end
        end
        @warnings.freeze
      end

      def to_write_script
        str = +''
        @write_script_lines = []
        generate_write_script_lines unless Tag.empty?(@value)
        unless @write_script_lines.empty?
          str << (info.empty? ? '' : "# INFO: #{@info}\n")
          @warnings.each do |w|
            str << "# WARNING: #{w}\n"
          end
          @write_script_lines.each do |l|
            unless @warnings.empty?
              str << '# ' unless @force_write
            end
            str << "#{l}\n"
          end
        end
        str
      end

      private

      def normalize(value)
        return EMPTY if value.nil?
        return EMPTY if value.is_a?(TrueClass) || value.is_a?(FalseClass)
        if value.is_a?(String)
          return EMPTY if value.strip.empty?
        elsif value.is_a?(Array)
          return value.flatten.map { |i| normalize(i.to_s) }
        elsif value.is_a?(Hash)
          return value.map { |k, v| [k, normalize(v.to_s)] }.to_h
        elsif value.is_a?(DateTime)
          return EMPTY if value.strftime('%F %T') == EMPTY_DATE
        elsif value.is_a?(Time)
          return normalize(value.to_datetime)
        end
        value
      end

      def init_raw_values(raw)
        self.class::EXIFTOOL_TAGS.each do |tag|
          @raw_values[tag] = normalize(raw[tag])
        end
      end

      def validate
        @errors = []
        @value_invalid = []
        return if Tag.empty?(@value)
        validate_type
      end

      def validate_string_size(value)
        bsize = value.bytesize
        return true if bsize <= self.class::MAX_BYTESIZE
        @errors << %(#{tag_name}: '#{value}' is #{bsize - self.class::MAX_BYTESIZE} bytes longer than allowed #{self.class::MAX_BYTESIZE})
        false
      end

      def validate_vs_previous
        @warnings = []
        return if @previous.nil?
        @previous.raw_values.each do |tag, val|
          @warnings << "#{tag_name} has original value: #{tag}='#{val}'" unless Tag.empty?(val)
        end
        @warnings.freeze
      end

      def freeze_values
        @value.freeze
        @raw_values.freeze
        @errors.freeze
        @value_invalid.freeze
        @warnings.freeze
      end
    end
  end
end
