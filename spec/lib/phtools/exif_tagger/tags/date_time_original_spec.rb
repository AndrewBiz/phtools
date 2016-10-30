#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/date_time_original'
require 'date'

describe ExifTagger::Tag::DateTimeOriginal do
  let(:tag_id) { :date_time_original }
  let(:tag_name) { 'DateTimeOriginal' }

  let(:val_ok) { DateTime.new(2014, 07, 31, 21, 1, 1) }
  let(:val_orig) { { 'DateTimeOriginal' => DateTime.new(2014, 01, 21, 11, 5, 5) } }
  let(:tag) { described_class.new(val_ok) }

  let(:val_nok_size) { '123456789012345678901234567890123' } # bytesize=33
  it_behaves_like 'any tag'

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:DateTimeOriginal=2014-07-31 21:01:01')
  end

  it_behaves_like 'any paranoid tag'

  it_behaves_like 'any date-tag'
end
