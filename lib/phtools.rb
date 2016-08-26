#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev
require 'phtools/version'
require 'pharrange'
require 'phbackup'
require 'phclname'
require 'phevent'
require 'phfixdate'
require 'phfixfmd'
require 'phls'
require 'phmtags'
require 'phrename'
require 'phtagset'

module PhTools
  def self.about
    about = <<TEXT
phtools v#{VERSION} is a bundle of small CLI tools for arranging, renaming, tagging
of the photo and video files. Helps to keep your photo-video assets in order.
Please run phtools in a terminal via CLI commands:
    pharrange\t(#{Phrename::about}),
    phbackup\t(#{Phbackup::about}),
    phclname\t(#{Phclname::about}),
    phevent\t(#{Phevent::about}),
    phfixdate\t(#{Phfixdate::about}),
    phfixmd\t(#{Phfixfmd::about}),
    phls\t(#{Phls::about}),
    phmtags\t(#{Phmtags::about}),
    phrename \t(#{Phrename::about}),
    phtagset\t(#{Phtagset::about}).
For more information run these commands with -h option.
TEXT
  end
end
