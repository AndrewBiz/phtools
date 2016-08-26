#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'rbconfig'

# foto tools
module PhTools
  # determine OS
  def self.os(os_string = RbConfig::CONFIG['host_os'])
    case os_string
    when /darwin/i then :macosx
    when /linux/i then :linux
    when /mswin|mingw|w32/i then :windows
    else :unknown
    end
  end

  # OS specific output implementation
  class OS
    def output(message)
      STDOUT.puts prepare(message)
    end
  end
end
