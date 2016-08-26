#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev
require 'phtools/utils/os'

module Utils
  # Unix specific functions
  class OSUnix < OS
    private

    def prepare(message)
      message.to_s
    end
  end
end
