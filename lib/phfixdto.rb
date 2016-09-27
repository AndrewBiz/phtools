#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'phtools/runner'

module PhTools
  class Phfixdto < Runner
    def self.about
      "fixes DateTimeOriginal tag to be equal to date-time-in-the-name"
    end
  end
end
