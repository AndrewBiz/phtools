#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'phtools/runner'

module PhTools
  class Phbackup < Runner

    def self.about
      "copies input files to backup folder"
    end

    private

    def validate_options
      @backup_dir = @options_cli['--backup'] || ''
      fail PhTools::Error, 'backup dir is not defined' if @backup_dir.empty?
    end

    def process_before
      if File.exist?(@backup_dir)
        fail PhTools::Error, "#{@backup_dir} is not a directory" unless
          File.directory?(@backup_dir)
        fail PhTools::Error, "#{@backup_dir} is not writable" unless
          File.writable?(@backup_dir)
      else
        begin
          Dir.mkdir @backup_dir
        rescue
          raise PhTools::Error, "Unable to make dir '#{@backup_dir}'"
        end
      end
    end

    def process_file(phfile)
      backup_path = File.join(@backup_dir,
                              phfile.basename + phfile.extname)
      FileUtils.cp(phfile.filename, backup_path, preserve: true, verbose: PhTools.debug)
      phfile
    rescue
      raise PhTools::Error, "file copying to #{@backup_dir}"
    end
  end
end
