#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'active_support/core_ext/string/inflections'
Dir.glob(File.join(__dir__, 'tag', '*.rb')).each { |f| require_relative f }

# ExifTagger helper methods
module ExifTagger
  TAGS_SUPPORTED = (Tag.constants - [:Tag, :TagDate]).map { |i| i.to_s.underscore.to_sym }
end
