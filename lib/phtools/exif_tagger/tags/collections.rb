#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag'

module ExifTagger
  module Tag
    # Collections (struct+)
    #   CollectionName
    #   CollectionURI
    class Collections < Tag
      TYPE = :hash_of_strings
      MAX_BYTESIZE = 32 # TODO
      VALID_KEYS = [:collection_name, :collection_uri]
      EXIFTOOL_TAGS = %w(CollectionName CollectionURI)

      def initialize(value_raw = {}, previous = nil)
        super
      end

      private

      def validate
        @errors = []
        @value_invalid = []
        return if Tag.empty?(@value)

        unknown_keys = @value.keys - VALID_KEYS
        unknown_keys.each do |k|
          @errors << %{#{tag_name}: KEY '#{k}' is unknown}
        end
        missed_keys = VALID_KEYS - @value.keys
        missed_keys.each do |k|
          @errors << %{#{tag_name}: KEY '#{k}' is missed}
        end
        unless @errors.empty?
          @value_invalid << @value
          @value = {}
        end
      end

      def generate_write_script_lines
        @write_script_lines = []
        unless @value.empty?
          @write_script_lines << %Q(-XMP-mwg-coll:Collections-={CollectionName=#{@value[:collection_name]}, CollectionURI=#{@value[:collection_uri]}})
          @write_script_lines << %Q(-XMP-mwg-coll:Collections+={CollectionName=#{@value[:collection_name]}, CollectionURI=#{@value[:collection_uri]}})
        end
      end
    end
  end
end
