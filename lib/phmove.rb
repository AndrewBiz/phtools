#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'phtools/runner'

module PhTools
  class Phmove < Runner
    def self.about
      'moves input files to target folder'
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
        if @arrange
          Dir.mkdir @raw_folder unless Dir.exist?(@raw_folder)
          Dir.mkdir @video_folder unless Dir.exist?(@video_folder)
        end
      rescue
        raise PhTools::Error, "Unable to make dir inside '#{@target_folder}'"
      end
    end

    def process_file(phfile)
      phfile_out = phfile.clone
      phfile_out.dirname = @target_folder if phfile_out.image_normal?
      phfile_out.dirname = @raw_folder if phfile_out.image_raw?
      phfile_out.dirname = @video_folder if phfile_out.video?
      phfile_out.dirname = @target_folder if phfile_out.audio?

      FileUtils.mv(phfile.filename, phfile_out.filename, verbose: PhTools.debug) unless phfile == phfile_out
      phfile_out

    rescue SystemCallError => e
      raise PhTools::Error, 'file moving - ' + e.message
    end

    def process_after
      return unless @arrange
      Dir.delete @raw_folder if Dir.exist?(@raw_folder) && Utils.dir_empty?(@raw_folder)
      Dir.delete @video_folder if Dir.exist?(@video_folder) && Utils.dir_empty?(@video_folder)
    rescue
      raise PhTools::Error, 'Unable to delete dir'
    end
  end
end
