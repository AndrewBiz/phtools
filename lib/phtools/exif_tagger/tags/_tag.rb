#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'active_support/core_ext'
require 'mini_exiftool'

module ExifTagger
  module Tag
    # Parent class for all tags
    class Tag
      include Comparable

      EMPTY = ''.freeze
      EXIFTOOL_TAGS = [].freeze
      MAX_BYTESIZE = 32

      attr_reader :errors, :value, :raw_values, :value_invalid, :warnings, :write_script_lines
      attr_accessor :info, :force_write

      def self.empty?(value)
        return value.empty? if value.is_a?(String) || value.is_a?(Array)
        false
      end

      def initialize(value = '', previous = nil)
        @raw_values = {}
        if value.class == MiniExiftool
          init_raw_values(value)
          @value = get_from_raw
        else
          @value = normalize(value)
        end
        @errors = []
        @value_invalid = []
        @warnings = []
        @write_script_lines = []
        @info = ''
        @force_write = false
        @previous = previous

        validate
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
        str = ''
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
        end
        value
      end

      def init_raw_values(raw)
        self.class::EXIFTOOL_TAGS.each do |tag|
          @raw_values[tag] = normalize(raw[tag])
        end
      end

      def get_from_raw
        @raw_values.each_value do |value|
          return value unless Tag.empty?(value)
        end
        EMPTY
      end

      def validate
        bsize = @value.bytesize
        return if bsize <= self.class::MAX_BYTESIZE
        @errors << %(#{tag_name}: '#{@value}' ) +
                   %(is #{bsize - self.class::MAX_BYTESIZE} bytes longer than allowed #{self.class::MAX_BYTESIZE})
        @value_invalid << @value
        @value = EMPTY
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
