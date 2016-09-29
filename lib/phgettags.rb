#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'phtools/runner'
require 'mini_exiftool'
require 'phtools/exif_tagger'

module PhTools
  class Phgettags < Runner
    def self.about
      'extracts the tags stored inside the file'
    end

    private

    def process_file(phfile)
      begin
        tags = MiniExiftool.new(phfile.filename,
                                numerical: false,
                                coord_format: '%d %d %.4f',
                                replace_invalid_chars: true,
                                composite: true,
                                timestamps: DateTime)
      rescue
        raise PhTools::Error, "EXIF tags reading - #{e.message}"
      end

      puts "******** FILE #{phfile} ********"

      if !@options_cli['--full_dump']
        puts format('%-29s %s', 'FileModifyDate', tags.FileModifyDate.to_s)
        ExifTagger::TAGS_SUPPORTED.each do |tag|
          puts tag.to_s.camelize
          ExifTagger::Tag.const_get(tag.to_s.camelize).const_get('EXIFTOOL_TAGS').each do |t|
            v = tags[t]
            v = 'EMPTY' if v.respond_to?(:empty?) && v.empty?
            if v.nil?
              puts format('  %-27s %s', t, 'NIL')
            else
              puts format('  %-27s %-10s %s', t, "(#{v.class})", v)
            end
          end
        end
      else # full_dump
        tags.to_hash.each do |t, v|
          puts format('%-29s %-10s %s', t, "(#{v.class})", v)
        end
      end

      return ''

    rescue => e
      raise PhTools::Error, "exif tags operating: #{e.message}"
    end
  end
end
