#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'phtools/runner'

module PhTools
  # list generation
  class Phls < Runner
    def self.about
      %Q{generates list of phtools friendly files}
    end

    def run!
      @options_cli['DIR_OR_FILE'] = ['.'] if @options_cli['DIR_OR_FILE'].empty?
      @options_cli['DIR_OR_FILE'].each do |item|
        if File.exist?(item)
          File.directory?(item) ? output_dir(item) : output_file(item)
        end
      end

    rescue SignalException
      PhTools.puts_error 'EXIT on user interrupt Ctrl-C'
      exit 1
    rescue => e
      PhTools.puts_error "FATAL: #{e.message}", e
      exit 1
    end

    private

    def output_dir(item)
      fmask = File.join(item, @options_cli['--recursive'] ? '**' : '',
                        "{#{@file_type.map { |i| "*.#{i}" } * ','}}")
      files_to_process = Dir.glob(fmask, File::FNM_CASEFOLD |
                                  File::FNM_DOTMATCH)
      files_to_process.each { |f| output_file(f) }
    end

    def output_file(file)
      @os.output(File.join(File.dirname(file), File.basename(file))) if
          @file_type.include?(File.extname(file).slice(1..-1).downcase)
    end
  end
end
