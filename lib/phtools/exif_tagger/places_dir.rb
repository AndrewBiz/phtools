#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'yaml'
require 'date'

# Hash Refine
module HashRefine
  refine Hash do
    def each_leaf(full_key = [], &blk)
      each do |k, v|
        current_key = full_key + [k]
        if v.kind_of? Hash
          v.each_leaf(current_key, &blk)
        else
          yield(current_key, v)
        end
      end
    end
  end
end

using HashRefine

# Foto tools
module ExifTagger
  # Places directory
  class PlacesDir
    include Enumerable

    attr_reader :filename, :errors

    def initialize(filename = '')
      fail PlacesDirectory, "file '#{filename}' does not exist" unless filename && File.exist?(filename)
      fail PlacesDirectory, "'#{filename}' is not a file" if File.directory?(filename)
      fail PlacesDirectory, "'#{filename}' should be yml type" unless File.extname(filename).downcase == '.yml'
      @filename = filename
      begin
        init_collection(YAML.load_file(filename))
      rescue => e
        raise PlacesDirectory, "reading '#{@filename}' - #{e.message}"
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
        str = "PLACES file '#{@filename}' is NOT VALID:\n"
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

    PLACE_TYPE = {
      world_region: String,
      country: String,
      country_code: String,
      state: String,
      city: String,
      location: String,
      gps_created: {
        gps_latitude: String,
        gps_latitude_ref: String,
        gps_longitude: String,
        gps_longitude_ref: String,
        gps_altitude: String,
        gps_altitude_ref: String }
    }

    def validate
      @errors = []
      place_type = simplify_hash(PLACE_TYPE)
      @collection.each do |place_id, place_def|
        place_cur = simplify_hash(place_def)
        missed_keys = place_type.keys - place_cur.keys
        missed_keys.each { |k| @errors << %(#{place_id}: '#{k}' is MISSED) }
        ok_keys = place_type.keys - missed_keys
        ok_keys.each do |k|
          val = place_cur[k]
          type = place_type[k]
          if val.nil? || !val.kind_of?(type)
            @errors << %(#{place_id}: '#{k}' is WRONG TYPE, should be #{type})
          else
            if val.respond_to?(:empty?) && val.empty?
              @errors << %(#{place_id}: '#{k}' is EMPTY)
            end
          end
        end
      end
    end

    def simplify_hash(hash = {})
      s_hash = {}
      hash.each_leaf do |k, v|
        s_key = k * '.'
        s_hash[s_key] = v
      end
      s_hash
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
