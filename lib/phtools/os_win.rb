#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'phtools/os'

module PhTools
  # OS platfor related logic
  class OSWin < PhTools::OS

    private

    def prepare(message)
      message.to_s.gsub(/#{"/"}/, '\\')
    end
  end
end
