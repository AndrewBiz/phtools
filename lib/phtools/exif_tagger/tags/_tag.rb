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

      EXIFTOOL_TAGS = [].freeze
      attr_reader :errors, :value, :raw_values, :value_invalid, :warnings, :write_script_lines
      attr_accessor :info, :force_write

      def initialize(value = '')
        @raw_values = {}
        if value.class == MiniExiftool
          init_raw_values(value)
          get_value_from_raw
        else
          @value = value
        end
        @errors = []
        @value_invalid = []
        @warnings = []
        @write_script_lines = []
        @info = ''
        @force_write = false
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
        if other.respond_to? :tag_id
          tag_id <=> other.tag_id
        else
          tag_id <=> other.to_s.to_sym
        end
      end

      def to_s
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
        generate_write_script_lines
        unless @write_script_lines.empty?
          str << print_info
          str << print_warnings
          str << print_lines
        end
        str
      end

      private

      def init_raw_values(raw)
        self.class::EXIFTOOL_TAGS.each do |tag|
          @raw_values[tag] = raw[tag]
        end
      end

      def get_value_from_raw
        @raw_values.each_value do |value|
          if value
            @value = value
            break
          end
        end
      end

      def freeze_values
        @value.freeze
        @raw_values.freeze
        @errors.freeze
        @value_invalid.freeze
        @warnings.freeze
      end

      def print_info
        @info.empty? ? '' : "# INFO: #{@info}\n"
      end

      def print_warnings
        str = ''
        @warnings.each do |w|
          str << "# WARNING: #{w}\n"
        end
        str
      end

      def print_lines
        str = ''
        @write_script_lines.each do |l|
          unless @warnings.empty?
            str << '# ' unless @force_write
          end
          str << "#{l}\n"
        end
        str
      end
    end
  end
end
