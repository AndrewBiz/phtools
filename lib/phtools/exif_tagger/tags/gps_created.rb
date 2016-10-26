#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_hash_of_strings'

module ExifTagger
  module Tag
    # GPS tags are used for camera location according to MWG 2.0)
    # GPSLatitude (rational64u[3])
    # GPSLatitudeRef (string[2] 'N' = North, 'S' = South)
    # GPSLongitude (rational64u[3])
    # GPSLongitudeRef (string[2] 'E' = East, 'W' = West)
    # GPSAltitude (rational64u)
    # GPSAltitudeRef (int8u 0 = Above Sea Level, 1 = Below Sea Level)
    class GpsCreated < TagHashOfStrings
      MAX_BYTESIZE = 64
      VALID_KEYS = [:gps_latitude, :gps_latitude_ref, :gps_longitude, :gps_longitude_ref, :gps_altitude, :gps_altitude_ref].freeze
      EXIFTOOL_TAGS = %w(
        GPSPosition
        GPSLatitude
        GPSLatitudeRef
        GPSLongitude
        GPSLongitudeRef
        GPSAltitude
        GPSAltitudeRef
      ).freeze

      private

      def get_from_raw
        { gps_latitude: @raw_values['GPSLatitude'], gps_latitude_ref: @raw_values['GPSLatitudeRef'], gps_longitude: @raw_values['GPSLongitude'], gps_longitude_ref: @raw_values['GPSLongitudeRef'], gps_altitude: @raw_values['GPSAltitude'], gps_altitude_ref: @raw_values['GPSAltitudeRef'] }
      end

      # def validate
      #   @errors = []
      #   @value_invalid = []
      #   return if Tag.empty?(@value)
      #
      #   unknown_keys = @value.keys - VALID_KEYS
      #   unknown_keys.each do |k|
      #     @errors << %(#{tag_name}: KEY '#{k}' is unknown)
      #   end
      #   missed_keys = VALID_KEYS - @value.keys
      #   missed_keys.each do |k|
      #     @errors << %(#{tag_name}: KEY '#{k}' is missed)
      #   end
      #   if @errors.empty?
      #     valid_values = ['N', 'S']
      #     unless valid_values.include? @value[:gps_latitude_ref]
      #       @errors << %(#{tag_name}: value of 'gps_latitude_ref' should be one of #{valid_values})
      #     end
      #     valid_values = ['E', 'W']
      #     unless valid_values.include? @value[:gps_longitude_ref]
      #       @errors << %(#{tag_name}: value of 'gps_longitude_ref' should be one of #{valid_values})
      #     end
      #     valid_values = ['Above Sea Level', 'Below Sea Level']
      #     unless valid_values.include? @value[:gps_altitude_ref]
      #       @errors << %(#{tag_name}: value of 'gps_altitude_ref' should be one of #{valid_values})
      #     end
      #   end
      #   unless @errors.empty?
      #     @value_invalid << @value
      #     @value = {}
      #   end
      # end

      def generate_write_script_lines
        @write_script_lines << %(-GPSLatitude="#{@value[:gps_latitude]}")
        @write_script_lines << %(-GPSLatitudeRef=#{@value[:gps_latitude_ref]})
        @write_script_lines << %(-GPSLongitude="#{@value[:gps_longitude]}")
        @write_script_lines << %(-GPSLongitudeRef=#{@value[:gps_longitude_ref]})
        @write_script_lines << %(-GPSAltitude=#{@value[:gps_altitude]})
        @write_script_lines << %(-GPSAltitudeRef=#{@value[:gps_altitude_ref]})
      end
    end
  end
end
