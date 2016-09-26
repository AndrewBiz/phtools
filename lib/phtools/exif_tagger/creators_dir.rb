#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'yaml'
require 'date'

module ExifTagger
  # Creators directiry
  class CreatorsDir
    include Enumerable

    attr_reader :filename, :errors

    def initialize(filename = '')
      fail CreatorsDirectory, "file '#{filename}' does not exist" unless filename && File.exist?(filename)
      fail CreatorsDirectory, "'#{filename}' is not a file" if File.directory?(filename)
      fail CreatorsDirectory, "'#{filename}' should be yml type" unless File.extname(filename).downcase == '.yml'

      @filename = filename
      begin
        init_collection(YAML.load_file(filename))
      rescue => e
        raise CreatorsDirectory, "reading '#{@filename}' - #{e.message}"
      end
      validate
      freeze
    end

    def each(&block)
      @collection.each(&block)
    end

    def to_s
      str = ''
      @collection.each { |k, v| str << "#{k} = #{v}" }
      str
    end

    def [](key)
      @collection[key.to_s.downcase.to_sym]
    end

    def valid?
      @errors.empty?
    end

    def error_message
      str = ''
      unless valid?
        str = "CREATORS file '#{@filename}' is NOT VALID:\n"
        @errors.each { |e| str << '    ' + e + "\n" }
      end
      str
    end

    private

    def init_collection(hash)
      @collection = {}
      @collection.default = {}
      hash.each do |key, value|
        @collection[key.to_s.downcase.to_sym] = value.dup
      end
    end

    def validate
      @errors = []
      @collection.each do |key, subkey|
        err = %(#{key}: :creator:)
        val = subkey[:creator]
        if val.nil?
          @errors << %(#{err} is MISSED)
        else
          if val.kind_of? Array
            if val.empty?
              @errors << %(#{err} is EMPTY, expected Array of strings, e.g. ["Creator1", "Creator2"])
            else
              val.each do |i|
                if i.to_s.empty?
                  @errors << %(#{err} has EMPTY parts, expected Array of strings, e.g. ["Creator1", "Creator2"])
                end
                unless i.kind_of? String
                  @errors << %(#{err} has NON-STRING parts, expected Array of strings, e.g. ["Creator1", "Creator2"])
                end
              end
            end
          else
            @errors << %(#{err} is WRONG TYPE, expected Array of strings, e.g. ["Creator1", "Creator2"])
          end
        end

        err = %(#{key}: :copyright:)
        val = subkey[:copyright]
        if val.nil?
          @errors << %(#{err} is MISSED)
        elsif val.to_s.empty?
          @errors << %(#{err} is EMPTY, expected String, e.g. "2014 Copyright")
        else
          unless val.kind_of? String
            @errors << %(#{err} is WRONG TYPE, expected String, e.g. "2014 Copyright")
          end
        end
      end
    end

    def freeze
      @filename.freeze
      @collection.freeze
      @collection.each do |key, subkey|
        subkey.freeze
        subkey.each { |k, v| v.freeze }
      end
      @errors.freeze
    end
  end
end
