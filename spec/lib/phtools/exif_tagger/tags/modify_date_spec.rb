#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/modify_date'
require 'date'

describe ExifTagger::Tag::ModifyDate do
  let(:val_ok) { 'now' }
  let(:val_orig) { { 'ModifyDate' => DateTime.now } }
  let(:tag) { described_class.new(val_ok) }

  it_behaves_like 'any tag'

  it 'knows it\'s ID' do
    expect(tag.tag_id).to be :modify_date
    expect(tag.tag_name).to eq 'ModifyDate'
  end

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-EXIF:ModifyDate=now')
  end

  it_behaves_like 'any paranoid tag'

  it_behaves_like 'any date-tag'
end
