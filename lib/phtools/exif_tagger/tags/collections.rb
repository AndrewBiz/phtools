#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative '_tag_hash_of_strings'

module ExifTagger
  module Tag
    # XMP-mwg-coll:Collections (struct+)
    #   CollectionName
    #   CollectionURI
    class Collections < TagHashOfStrings
      MAX_BYTESIZE = 64
      VALID_KEYS = [:collection_name, :collection_uri].freeze
      EXIFTOOL_TAGS = %w(CollectionName CollectionURI).freeze

      private

      def get_from_raw
        result = {}
        v = @raw_values['CollectionName']
        v = v.split('; ') if v.is_a?(String)
        result[:collection_name] = v[0]

        v = @raw_values['CollectionURI']
        v = v.split('; ') if v.is_a?(String)
        result[:collection_uri] = v[0]

        result
      end

      def generate_write_script_lines
        @write_script_lines << %(-XMP-mwg-coll:Collections-={CollectionName=#{@value[:collection_name]}, CollectionURI=#{@value[:collection_uri]}})
        @write_script_lines << %(-XMP-mwg-coll:Collections+={CollectionName=#{@value[:collection_name]}, CollectionURI=#{@value[:collection_uri]}})
      end
    end
  end
end
