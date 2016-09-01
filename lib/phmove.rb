#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'phtools/runner'

module PhTools
  class Phmove < Runner
    def self.about
      "moves input files into target folder"
    end
    private

    def validate_options
      @target_folder = @options_cli['TARGET_FOLDER']
      @arrange = @options_cli['--arrange']
      if @arrange
        @raw_folder = File.join(@target_folder, 'RAW')
        @video_folder = File.join(@target_folder, 'VIDEO')
      else
        @raw_folder = @target_folder
        @video_folder = @target_folder
      end
    end

    def process_before
      fail PhTools::Error, "#{@target_folder} does not exist" unless File.exist?(@target_folder)
      fail PhTools::Error, "#{@target_folder} is not a directory" unless File.directory?(@target_folder)
      begin
        Dir.mkdir @raw_folder unless Dir.exist?(@raw_folder)
        Dir.mkdir @video_folder unless Dir.exist?(@video_folder)
      rescue
        raise PhTools::Error, "Unable to make dir inside '#{@target_folder}'"
      end
    end

    def process_file(ftfile)
      ftfile_out = ftfile.clone
      file_type = ftfile.extname.slice(1..-1).downcase
      case
      when FILE_TYPE_IMAGE_NORMAL.include?(file_type)
        ftfile_out.dirname = @target_folder
      when FILE_TYPE_IMAGE_RAW.include?(file_type)
        ftfile_out.dirname = @raw_folder
      when FILE_TYPE_VIDEO.include?(file_type)
        ftfile_out.dirname = @video_folder
      when FILE_TYPE_AUDIO.include?(file_type)
        ftfile_out.dirname = @target_folder
      end

      FileUtils.mv(ftfile.filename, ftfile_out.filename) unless ftfile == ftfile_out
      ftfile_out
    rescue SystemCallError => e
      raise PhTools::Error, 'file moving - ' + e.message
    end
  end
end
