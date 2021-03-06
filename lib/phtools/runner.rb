#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8

# (c) ANB Andrew Bizyaev

require 'phtools/utils/ruby_version.rb'
require 'phtools/version'
require 'phtools/utils'
require 'phtools/error.rb'
require 'phtools/ph_file.rb'
require 'docopt'

module PhTools
  # Main class processing input stream
  class Runner
    def initialize(usage, file_type = [])
      case Utils.os
      when :windows
        # workaround for win32
        ARGV.map! { |a| a.encode('utf-8', 'filesystem') }
        @os = Utils::OSWin.new
      else
        @os = Utils::OSUnix.new
      end
      @tool_name = File.basename($PROGRAM_NAME)
      @options_cli = Docopt.docopt(usage, version: "v#{PhTools::VERSION}")
      @file_type = file_type
      PhTools.debug = true if @options_cli['--debug']

      validate_options
    rescue Docopt::Exit => e
      STDERR.puts e.message
      exit 1
    rescue StandardError => e
      PhTools.puts_error "FATAL: #{e.message}", e
      exit 1
    ensure
      if PhTools.debug
        STDERR.puts 'Runner Instance Variables: '
        STDERR.puts context
      end
    end

    def run!
      return if STDIN.tty?
      ARGV.clear
      process_before

      ARGF.each_line do |line|
        filename = line.chomp
        begin
          PhFile.validate_file!(filename, @file_type)
          phfile = PhFile.new(filename)
          @os.output process_file(phfile)
        rescue PhTools::Error => e
          PhTools.puts_error "ERROR: '#{filename}' - #{e.message}", e
        end
      end

      process_after
    rescue SignalException
      PhTools.puts_error 'EXIT on user interrupt Ctrl-C'
      exit 1
    rescue StandardError => e
      PhTools.puts_error "FATAL: #{e.message}", e
      exit 1
    end

    private

    def validate_options; end

    def process_before; end

    def process_file(file)
      file
    end

    def process_after; end

    def context
      instance_variables.map do |item|
        { item => instance_variable_get(item) }
      end
    end
  end
end
