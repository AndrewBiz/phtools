#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev
require "phtools/version"

module PhTools
  def self.about
    %Q{phtools, v#{Phtools::VERSION}, is a bundle of small CLI tools for arranging, renaming, tagging of the photo and video files. Helps to keep your photo-video assets in order.
    Please run phtools in a terminal via CLI commands: phls, phrename, phbackup, pharrange, phclname, phevent, phfixdate, phfixmd, phmtags, phtagset}
  end
end
