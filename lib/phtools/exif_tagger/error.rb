#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

module ExifTagger
  class Error < StandardError; end
  class UnknownTag < Error; end
  class WriteTag < Error; end
  class CreatorsDirectory < Error; end
  class PlacesDirectory < Error; end
end
