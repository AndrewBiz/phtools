#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/create_date'
require 'date'

describe ExifTagger::Tag::CreateDate do
  let(:tag_id) { :create_date }
  let(:tag_name) { 'CreateDate' }

  let(:val_ok) { DateTime.new(2014, 8, 12, 21, 58, 55) }
  let(:val_orig) { { 'CreateDate' => DateTime.new(2014, 01, 21, 11, 5, 5) } }
  let(:tag) { described_class.new(val_ok) }

  it_behaves_like 'any tag'

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:CreateDate=2014-08-12 21:58:55')
  end

  it_behaves_like 'any paranoid tag'

  it_behaves_like 'any date-tag'
end
