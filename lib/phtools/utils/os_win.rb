#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require_relative 'os'

module Utils
  # OS platfor related logic
  class OSWin < OS

    private

    def prepare(message)
      message.to_s.gsub(/#{"/"}/, '\\')
    end
  end
end
