#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/location'

describe ExifTagger::Tag::Location do
  let(:tag_id) { :location }
  let(:tag_name) { 'Location' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { 'Orekhovo-Borisovo' }
  let(:val_orig) { { 'Location' => 'Maidan' } }
  let(:val_orig_empty) { { 'Sub-location' => '', 'Location' => '', 'LocationShownSublocation' => '' } }

  let(:hash_ok) { { 'Sub-location' => 'Orekhovo-Borisovo', 'Location' => 'Maidan', 'LocationShownSublocation' => 'Home' } }
  let(:hash_last_is_empty) { { 'Sub-location' => 'Orekhovo-Borisovo', 'Location' => 'Maidan', 'LocationShownSublocation' => '' } }
  let(:hash_last_is_all_spaces) { { 'Sub-location' => 'Orekhovo-Borisovo', 'Location' => 'Maidan', 'LocationShownSublocation' => '    ' } }
  let(:hash_last_is_nil) { { 'Sub-location' => 'Orekhovo-Borisovo', 'Location' => 'Maidan', 'LocationShownSublocation' => nil } }
  let(:hash_with_nondefined) { { 'Sub-location' => 'Orekhovo-Borisovo', 'Location' => 'Maidan' } }
  let(:hash_with_all_bool) { { 'Sub-location' => true, 'Location' => true, 'LocationShownSublocation' => false } }
  let(:hash_with_all_empty) { { 'Sub-location' => '', 'Location' => '', 'LocationShownSublocation' => '' } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:Location=Orekhovo-Borisovo')
  end

  it 'does NOT generate write_script for EMPTY value' do
    tag = described_class.new('')
    expect(tag.to_write_script).not_to include('-MWG:Location=')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) { '123456789012345678901234567890123' } # bytesize=33
  it_behaves_like 'any string tag'

  it_behaves_like 'any tag who cares about previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'
  context 'when gets partially defined mini_exiftool hash' do
    subject { described_class.new(mhash) }
    it "chooses correct main value = 1st when 1 and 3 exist" do
      hash = { 'Sub-location' => 'Orekhovo-Borisovo', 'Location' => '', 'LocationShownSublocation' => 'Home' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.value).to eq 'Orekhovo-Borisovo'
      expect(subject.warnings).to be_empty
    end

    it "chooses correct main value = 2nd when 2 and 3 exist" do
      hash = { 'Sub-location' => '', 'Location' => 'Maidan', 'LocationShownSublocation' => 'Home' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.value).to eq 'Maidan'
      expect(subject.warnings).to be_empty
    end

    it "chooses correct main value = 3rd when only 3 exists" do
      hash = { 'Sub-location' => '', 'Location' => '', 'LocationShownSublocation' => 'Home' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.value).to eq 'Home'
      expect(subject.warnings).to be_empty
    end
  end
end
