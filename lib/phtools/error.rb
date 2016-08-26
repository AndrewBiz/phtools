#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'nesty'

# Foto tools
module PhTools
  @debug = false
  def self.debug=(val)
    @debug = val
  end

  def self.debug
    @debug
  end

  def self.puts_error(msg, e = nil)
    prefix = File.basename($PROGRAM_NAME, '.rb')
    STDERR.puts "#{prefix}: #{msg}"
    if @debug && !e.nil?
      if e.respond_to?(:cause) && !e.cause.nil?
        STDERR.puts "#{prefix}: CAUSE: #{e.cause} - #{e.cause.message}"
      end
      e.backtrace.each do |b|
        STDERR.puts "#{prefix}: BACKTRACE: #{b}"
      end
    end
  end

  class Error < Nesty::NestedStandardError; end
  class ExiftoolTagger < Error; end
end
