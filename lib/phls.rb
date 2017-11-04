#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8

# (c) ANB Andrew Bizyaev

require 'phtools/runner'

module PhTools
  class Phls < Runner
    def self.about
      %(generates list of phtools friendly files)
    end

    def run!
      @dirs_to_scan.each do |dir|
        fmask = File.join(dir, @recursive ? '**' : '', "{#{@filemasks * ','}}")
        files = Dir.glob(fmask, File::FNM_CASEFOLD)
        files_sorted = files.sort_by(&:downcase)
        files_sorted.each { |f| output_file(PhFile.new(f)) if File.file?(f) }
      end
    rescue SignalException
      PhTools.puts_error 'EXIT on user interrupt Ctrl-C'
      exit 1
    rescue StandardError => e
      PhTools.puts_error "FATAL: #{e.message}", e
      exit 1
    end

    private

    def validate_options
      @dirs_to_scan = []
      @filemasks = []
      @options_cli['DIR_OR_FILEMASK'].each do |item|
        File.directory?(item) ? @dirs_to_scan << item : @filemasks << item
      end
      @dirs_to_scan = ['.'] if @dirs_to_scan.empty?
      @filemasks = ['*.*'] if @filemasks.empty?
      @recursive = @options_cli['--recursive']
      @range = @options_cli['--range']
      return unless @range
      /^(?<_range1>[[:alnum:]]+)\.\.(?<_range2>[[:alnum:]]+)/ =~ @range
      @range_start = Regexp.last_match(:_range1)
      @range_end = Regexp.last_match(:_range2)
      @ending_size = [@range_start.size, @range_end.size].max
    end

    def output_file(phfile)
      return unless @file_type.include?(phfile.type)
      if @range
        return unless (@range_start..@range_end).include?(phfile.basename_clean.slice(-@ending_size, @ending_size))
      end
      @os.output(phfile)
    end
  end
end
