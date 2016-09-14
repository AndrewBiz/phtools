#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

module PhTools
  @debug = false
  def self.debug=(val)
    @debug = val
  end

  def self.debug
    @debug
  end

  def self.drill_down_error(e, level, prefix)
    return if e.nil?
    STDERR.puts "#{prefix}: CAUSE#{level}: #{e.class} - #{e.message}"
    e.backtrace.each do |b|
      STDERR.puts "#{prefix}: CAUSE#{level} BACKTRACE: #{b}"
    end
    drill_down_error(e.cause, level+1, prefix)
  end

  def self.puts_error(msg, e = nil)
    prefix = File.basename($PROGRAM_NAME, '.rb')
    STDERR.puts "#{prefix}: #{msg}"
    drill_down_error(e, 0, prefix) if @debug
  end

  class Error < StandardError
  end

  class ExiftoolTagger < Error
  end
end
