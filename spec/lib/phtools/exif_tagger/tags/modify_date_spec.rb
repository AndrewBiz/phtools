#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/modify_date'
require 'date'

describe ExifTagger::Tag::ModifyDate do
  let(:tag_id) { :modify_date }
  let(:tag_name) { 'ModifyDate' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { 'now' }
  let(:val_orig) { { 'ModifyDate' => DateTime.now } }
  let(:val_orig_empty) { {'ModifyDate' => '' } }

  let(:hash_ok) { { 'ModifyDate' => 'now' } }
  let(:hash_last_is_empty) { { 'ModifyDate' => '' } }
  let(:hash_last_is_all_spaces) { { 'ModifyDate' => '   ' } }
  let(:hash_last_is_nil) { { 'ModifyDate' => nil } }
  let(:hash_with_nondefined) { {} }
  let(:hash_with_all_bool) { { 'ModifyDate' => false } }
  let(:hash_with_all_empty) { { 'ModifyDate' => '' } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-EXIF:ModifyDate=now')
  end

  it 'does NOT generate write_script for EMPTY value' do
    tag = described_class.new('')
    expect(tag.to_write_script).not_to include('-EXIF:=')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) { '123456789012345678901234567890123' } # bytesize=33
  it_behaves_like 'any date-tag'

  it_behaves_like 'any tag who cares about previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'
end
