#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev
require "phtools/version"

module PhTools
  def self.about
    %Q{\nphtools v#{PhTools::VERSION} is a bundle of small CLI tools for arranging, renaming, tagging of the photo and video files. Helps to keep your photo-video assets in order. \nPlease run phtools in a terminal via CLI commands: phls, phrename, phbackup, pharrange, phclname, phevent, phfixdate, phfixmd, phmtags, phtagset.\nFor more information run these commands with -h option.}
  end
end
