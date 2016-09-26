#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

Dir.glob(File.join(__dir__, 'tag', '*.rb')).each { |f| require_relative f }

# ExifTagger helper methods
module ExifTagger
  TAGS_SUPPORTED = (Tag.constants - [:Tag]).map { |i| i.to_s.underscore.to_sym }
end
