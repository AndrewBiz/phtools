#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'phtools/version'
require 'phtools/ruby_version.rb'
require 'phtools/os_win.rb'
require 'phtools/os_unix.rb'
require 'phtools/error.rb'
require 'phtools/ph_file.rb'
require 'docopt'

# Foto Tools
module PhTools
  # Main class processing input stream
  class Runner
    def initialize(usage, file_type = [])
      case PhTools.os
      when :windows
        # workaround for win32
        ARGV.map! { |a| a.encode('utf-8', 'filesystem') }
        @os = OSWin.new
      else
        @os = OSUnix.new
      end
      @tool_name = File.basename($PROGRAM_NAME)
      @options_cli = Docopt.docopt(usage, version: "v#{PhTools::VERSION}")
      @file_type = file_type
      PhTools.debug = true if @options_cli['--debug']
      PhTools.puts_error "OPTIONS = #{@options_cli}" if PhTools.debug

      validate_options

    rescue Docopt::Exit => e
      STDERR.puts e.message
      exit 0
    rescue => e
      PhTools.puts_error "FATAL: #{e.message}", e
      exit 1
    end

    def run!
      return if STDIN.tty?
      ARGV.clear
      process_before

      ARGF.each_line do |line|
        filename = line.chomp
        begin
          FTFile.validate_file!(filename, @file_type)
          ftfile = FTFile.new(filename)
          @os.output process_file(ftfile)
        rescue PhTools::Error => e
          PhTools.puts_error "ERROR: '#{filename}' - #{e.message}", e
        end
      end

      process_after

    rescue SignalException
      PhTools.puts_error 'EXIT on user interrupt Ctrl-C'
      exit 1
    rescue => e
      PhTools.puts_error "FATAL: #{e.message}", e
      exit 1
    end

    private

    def validate_options
    end

    def process_before
    end

    def process_file(file)
      file
    end

    def process_after
    end
  end
end
