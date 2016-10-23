#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/world_region'

describe ExifTagger::Tag::WorldRegion do
  let(:tag_id) { :world_region }
  let(:tag_name) { 'WorldRegion' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { 'Asia' }
  let(:val_orig) { { 'LocationShownWorldRegion' => 'America' } }
  let(:val_orig_empty) { { 'LocationShownWorldRegion' => '' } }

  let(:hash_ok) { { 'LocationShownWorldRegion' => 'Asia' } }
  let(:hash_last_is_empty) { { 'LocationShownWorldRegion' => '' } }
  let(:hash_last_is_all_spaces) { { 'LocationShownWorldRegion' => '   ' } }
  let(:hash_last_is_nil) { { 'LocationShownWorldRegion' => nil } }
  let(:hash_with_nondefined) { {} }
  let(:hash_with_all_bool) { { 'LocationShownWorldRegion' => false } }
  let(:hash_with_all_empty) { { 'LocationShownWorldRegion' => '' } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-XMP:LocationShownWorldRegion=Asia')
  end

  it 'does NOT generate write_script for EMPTY value' do
    tag = described_class.new('')
    expect(tag.to_write_script).not_to include('-XMP:LocationShownWorldRegion=')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) { '12345678901234567890123456789012345678901234567890123456789012345' } # bytesize=65
  it_behaves_like 'any string tag'

  it_behaves_like 'any tag with previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'
end
