#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev
require 'phtools/os'

module PhTools
  # Unix specific functions
  class OSUnix < PhTools::OS
    private

    def prepare(message)
      message.to_s
    end
  end
end
