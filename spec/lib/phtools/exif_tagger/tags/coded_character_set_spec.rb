#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/coded_character_set'

describe ExifTagger::Tag::CodedCharacterSet do
  let(:tag_id) { :coded_character_set }
  let(:tag_name) { 'CodedCharacterSet' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { 'UTF8' }
  let(:val_orig) { { 'CodedCharacterSet' => 'UTF8' } }
  let(:val_orig_empty) { { 'CodedCharacterSet' => '' } }

  let(:hash_ok) { { 'CodedCharacterSet' => 'UTF8' } }
  let(:hash_last_is_empty) { { 'CodedCharacterSet' => '' } }
  let(:hash_last_is_all_spaces) { { 'CodedCharacterSet' => '    ' } }
  let(:hash_last_is_nil) { { 'CodedCharacterSet' => nil } }
  let(:hash_with_nondefined) { {} }
  let(:hash_with_all_bool) { { 'CodedCharacterSet' => true } }
  let(:hash_with_all_empty) { { 'CodedCharacterSet' => '' } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-IPTC:CodedCharacterSet=UTF8')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) { '123456789012345678901234567890123' } # bytesize=33
  it_behaves_like 'any string_tag'

  it_behaves_like 'any tag with previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'
end
