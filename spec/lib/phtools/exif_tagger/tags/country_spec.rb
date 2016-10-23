#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/country'

describe ExifTagger::Tag::Country do
  let(:tag_id) { :country }
  let(:tag_name) { 'Country' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { 'Russia' }
  let(:val_orig) { { 'Country' => 'Ukraine' } }
  let(:val_orig_empty) { { 'Country-PrimaryLocationName' => '', 'Country' => '', 'LocationShownCountryName' => '' } }

  let(:hash_ok) { { 'Country-PrimaryLocationName' => 'Russia', 'Country' => 'Ukraine', 'LocationShownCountryName' => 'USA' } }
  let(:hash_last_is_empty) { { 'Country-PrimaryLocationName' => 'Russia', 'Country' => 'Ukraine', 'LocationShownCountryName' => '' } }
  let(:hash_last_is_all_spaces) { { 'Country-PrimaryLocationName' => 'Russia', 'Country' => 'Ukraine', 'LocationShownCountryName' => '      ' } }
  let(:hash_last_is_nil) { { 'Country-PrimaryLocationName' => 'Russia', 'Country' => 'Ukraine', 'LocationShownCountryName' => nil } }
  let(:hash_with_nondefined) { { 'Country-PrimaryLocationName' => 'Russia', 'LocationShownCountryName' => 'USA' } }
  let(:hash_with_all_bool) { { 'Country-PrimaryLocationName' => true, 'Country' => false, 'LocationShownCountryName' => true } }
  let(:hash_with_all_empty) { { 'Country-PrimaryLocationName' => '', 'Country' => '', 'LocationShownCountryName' => '' } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:Country=Russia')
  end

  it 'does NOT generate write_script for EMPTY value' do
    tag = described_class.new('')
    expect(tag.to_write_script).not_to include('-MWG:Country=')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) { '12345678901234567890123456789012345678901234567890123456789012345' } # bytesize=65
  it_behaves_like 'any string tag'

  it_behaves_like 'any tag with previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'

  context 'when gets partially defined mini_exiftool hash' do
    subject { described_class.new(mhash) }
    it "chooses correct main value = 1st when 1 and 3 exist" do
      hash = { 'Country-PrimaryLocationName' => 'Russia', 'Country' => '', 'LocationShownCountryName' => 'USA' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.value).to eq 'Russia'
      expect(subject.warnings).to be_empty
    end

    it "chooses correct main value = 2nd when 2 and 3 exist" do
      hash = { 'Country-PrimaryLocationName' => '', 'Country' => 'Ukraine', 'LocationShownCountryName' => 'USA' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.value).to eq 'Ukraine'
      expect(subject.warnings).to be_empty
    end

    it "chooses correct main value = 3rd when only 3 exists" do
      hash = { 'Country-PrimaryLocationName' => '', 'Country' => '', 'LocationShownCountryName' => 'USA' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.value).to eq 'USA'
      expect(subject.warnings).to be_empty
    end
  end
end
