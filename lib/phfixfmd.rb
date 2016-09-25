#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'phtools/runner'

module PhTools
  class Phfixfmd < Runner

    def self.about
      "fixes FileModifyDate to be equal to date-time-in-the-name"
    end

    private

    def process_file(phfile)
      fail PhTools::Error, 'wrong date-time in the name' unless
        phfile.date_time_ok?
      begin
        File.utime(Time.now, phfile.date_time_to_time, phfile.filename)
      rescue
        raise PhTools::Error.new, 'setting file modify date'
      end
      phfile
    end
  end
end
