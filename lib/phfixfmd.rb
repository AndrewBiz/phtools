#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'phtools/runner'

module PhTools
  class Phfixfmd < Runner
    def self.about
      "fixes FileModifyDate to be equal to date-time-in-the-name"
    end
  end
end
