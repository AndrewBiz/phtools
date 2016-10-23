#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/image_unique_id'

describe ExifTagger::Tag::ImageUniqueId do
  let(:tag_id) { :image_unique_id }
  let(:tag_name) { 'ImageUniqueId' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { %(20140413-172725-002) }
  let(:val_orig) { { 'ImageUniqueID' => '20140301-180023-001' } }
  let(:val_orig_empty) { { 'ImageUniqueID' => '' } }

  let(:hash_ok) { { 'ImageUniqueID' => '20140413-172725-002' } }
  let(:hash_last_is_empty) { { 'ImageUniqueID' => '' } }
  let(:hash_last_is_all_spaces) { { 'ImageUniqueID' => '    ' } }
  let(:hash_last_is_nil) { { 'ImageUniqueID' => nil } }
  let(:hash_with_nondefined) { {} }
  let(:hash_with_all_bool) { { 'ImageUniqueID' => false } }
  let(:hash_with_all_empty) { { 'ImageUniqueID' => '' } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-ImageUniqueID=20140413-172725-002')
  end

  it 'does NOT generate write_script for EMPTY value' do
    tag = described_class.new('')
    expect(tag.to_write_script).not_to include('-ImageUniqueID=')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) { '123456789012345678901234567890123' } # bytesize=33
  it_behaves_like 'any string tag'

  it_behaves_like 'any tag who cares about previous value'
  context 'when gets both new and previous value' do
    let(:previous_value) { described_class.new(mhash) }
    let(:tag) { described_class.new(val_ok, previous_value) }

    it "ignores previous value which was not made by phtools" do
      val_orig_nok = { 'ImageUniqueID' => 'ab3b4bc6ba4bb2c343ab' }
      allow(mhash).to receive(:[]) { |tag| val_orig_nok[tag] }

      expect(tag.previous).not_to be_nil
      expect(tag.value).to eq(val_ok)
      expect(tag.raw_values).to be_empty
      expect(tag.to_s).to include(val_ok.to_s)
      expect(tag).to be_valid
      expect(tag.errors).to be_empty
      expect(tag.value_invalid).to be_empty
      expect(tag.warnings).to be_empty
      expect(tag.warnings.inspect).not_to include('has original value:')
    end
  end

  it_behaves_like 'any tag with MiniExiftool hash input'
end
