#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

module Utils
  def self.dir_empty?(dir)
    (Dir.entries(dir) - ['.', '..']).empty?
  end
end
