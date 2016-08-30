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
      @dirs_to_scan.each do |dir|
        fmask = File.join(dir, @options_cli['--recursive'] ? '**' : '', "{#{@filemasks * ','}}")
        Dir.glob(fmask, File::FNM_CASEFOLD).each { |f| output_file(f) if File.file?(f) }
      end

    rescue SignalException
      PhTools.puts_error 'EXIT on user interrupt Ctrl-C'
      exit 1
    rescue => e
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
    end

    def output_file(file)
      ftype = File.extname(file).empty? ? '' : File.extname(file).slice(1..-1).downcase
      @os.output(File.join(File.dirname(file), File.basename(file))) if @file_type.include?(ftype)
    end
  end
end
