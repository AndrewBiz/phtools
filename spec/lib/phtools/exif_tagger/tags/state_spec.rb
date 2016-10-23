#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/state'

describe ExifTagger::Tag::State do
  let(:tag_id) { :state }
  let(:tag_name) { 'State' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { 'Moscow oblast' }
  let(:val_orig) { { 'State' => 'Sverdlovsk oblast' } }
  let(:val_orig_empty) { { 'Province-State' => '', 'State' => '', 'LocationShownProvinceState' => '' } }

  let(:hash_ok) { { 'Province-State' => 'Moscow oblast', 'State' => 'Leningrad', 'LocationShownProvinceState' => 'Kiev' } }
  let(:hash_last_is_empty) { { 'Province-State' => 'Moscow oblast', 'State' => 'Leningrad', 'LocationShownProvinceState' => '' } }
  let(:hash_last_is_all_spaces) { { 'Province-State' => 'Moscow oblast', 'State' => 'Leningrad', 'LocationShownProvinceState' => '     ' } }
  let(:hash_last_is_nil) { { 'Province-State' => 'Moscow oblast', 'State' => 'Leningrad', 'LocationShownProvinceState' => nil } }
  let(:hash_with_nondefined) { { 'Province-State' => 'Moscow oblast', 'State' => 'Leningrad' } }
  let(:hash_with_all_bool) { { 'Province-State' => true, 'State' => true, 'LocationShownProvinceState' => false } }
  let(:hash_with_all_empty) { { 'Province-State' => '', 'State' => '', 'LocationShownProvinceState' => '' } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:State=Moscow oblast')
  end

  it 'does NOT generate write_script for EMPTY value' do
    tag = described_class.new('')
    expect(tag.to_write_script).not_to include('-MWG:State=')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) { '123456789012345678901234567890123' } # bytesize=33
  it_behaves_like 'any string tag'

  it_behaves_like 'any tag who cares about previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'

  context 'when gets partially defined mini_exiftool hash' do
    subject { described_class.new(mhash) }
    it "chooses correct main value = 1st when 1 and 3 exist" do
      hash = { 'Province-State' => 'Moscow oblast', 'State' => '', 'LocationShownProvinceState' => 'Kiev' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.value).to eq 'Moscow oblast'
      expect(subject.warnings).to be_empty
    end

    it "chooses correct main value = 2nd when 2 and 3 exist" do
      hash = { 'Province-State' => '', 'State' => 'Leningrad', 'LocationShownProvinceState' => 'Kiev' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.value).to eq 'Leningrad'
      expect(subject.warnings).to be_empty
    end

    it "chooses correct main value = 3rd when only 3 exists" do
      hash = { 'Province-State' => '', 'State' => false, 'LocationShownProvinceState' => 'Kiev' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.value).to eq 'Kiev'
      expect(subject.warnings).to be_empty
    end
  end
end
