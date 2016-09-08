#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev
require 'phtools/version'
require 'phbackup'
require 'phevent'
require 'phfixdate'
require 'phfixfmd'
require 'phls'
require 'phmove'
require 'phmtags'
require 'phrename'
require 'phtagset'

module PhTools
  def self.about
    about = <<TEXT
phtools v#{VERSION} is a bundle of small CLI tools for arranging, renaming, tagging
of the photo and video files. Helps to keep your photo-video assets in order.
Please run phtools in a terminal via CLI commands:
    phls\t(#{Phls::about}),
    phmove\t(#{Phmove::about}),
    phbackup\t(#{Phbackup::about}),
    phrename\t(#{Phrename::about}),
    phevent\t(#{Phevent::about}),
    phfixdate\t(#{Phfixdate::about}),
    phfixfmd\t(#{Phfixfmd::about}),
    phmtags\t(#{Phmtags::about}),
    phtagset\t(#{Phtagset::about}).
For more information run these commands with -h option.
General info about phtools usage see at https://github.com/AndrewBiz/phtools.git
TEXT
  end
end
