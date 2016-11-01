#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/date_time_original'
require 'date'

describe ExifTagger::Tag::DateTimeOriginal do
  let(:tag_id) { :date_time_original }
  let(:tag_name) { 'DateTimeOriginal' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { DateTime.new(2014, 1, 21, 11, 5, 5) }
  let(:val_orig) { { 'DateTimeOriginal' => DateTime.new(2014, 01, 21, 11, 5, 5), 'SubSecTimeOriginal' => 123, 'DateCreated' => '2005:05:05', 'TimeCreated' => '05:05:05+05:00' } }
  let(:val_orig_empty) { { 'DateTimeOriginal' => '', 'SubSecTimeOriginal' => '', 'DateCreated' => '', 'TimeCreated' => '' } }

  let(:hash_ok) { { 'DateTimeOriginal' => DateTime.new(2014, 01, 21, 11, 5, 5), 'SubSecTimeOriginal' => 123, 'DateCreated' => '2005:05:05', 'TimeCreated' => '05:05:05+05:00' } }
  let(:hash_last_is_empty) { { 'DateTimeOriginal' => DateTime.new(2014, 01, 21, 11, 5, 5), 'SubSecTimeOriginal' => 123, 'DateCreated' => '2005:05:05', 'TimeCreated' => '' } }
  let(:hash_last_is_all_spaces) { { 'DateTimeOriginal' => DateTime.new(2014, 01, 21, 11, 5, 5), 'SubSecTimeOriginal' => 123, 'DateCreated' => '2005:05:05', 'TimeCreated' => '     ' } }
  let(:hash_last_is_nil) { { 'DateTimeOriginal' => DateTime.new(2014, 01, 21, 11, 5, 5), 'SubSecTimeOriginal' => 123, 'DateCreated' => '2005:05:05', 'TimeCreated' => nil } }
  let(:hash_with_nondefined) { { 'DateTimeOriginal' => DateTime.new(2014, 01, 21, 11, 5, 5), 'DateCreated' => '2005:05:05', 'TimeCreated' => '05:05:05+05:00' } }
  let(:hash_with_all_bool) { { 'DateTimeOriginal' => false, 'SubSecTimeOriginal' => true, 'DateCreated' => false, 'TimeCreated' => false } }
  let(:hash_with_all_empty) { { 'DateTimeOriginal' => '', 'SubSecTimeOriginal' => nil, 'DateCreated' => '', 'TimeCreated' => '' } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:DateTimeOriginal=2014-01-21 11:05:05')
  end

  it 'does NOT generate write_script for EMPTY value' do
    tag = described_class.new('')
    expect(tag.to_write_script).not_to include('-MWG:DateTimeOriginal=')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) { '123456789012345678901234567890123' } # bytesize=33
  it_behaves_like 'any date-tag'

  it_behaves_like 'any tag who cares about previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'

  context 'when gets partially defined mini_exiftool hash' do
    subject { described_class.new(mhash) }
    it "chooses correct main value with DateCreated (DateTime)" do
      hash = { 'DateTimeOriginal' => '', 'SubSecTimeOriginal' => '123', 'DateCreated' => DateTime.new(2016, 11, 01, 21, 53, 3), 'TimeCreated' => '05:05:05+05:00' }
      allow(mhash).to receive(:[]) { |tag| hash[tag] }

      expect(subject.raw_values['DateTimeOriginal']).to be_empty
      expect(subject.raw_values['SubSecTimeOriginal']).to eq '123'
      expect(subject.raw_values['DateCreated']).to eq DateTime.new(2016, 11, 01, 21, 53, 3)
      expect(subject.raw_values['TimeCreated']).to eq '05:05:05+05:00'
      expect(subject.value).to eq DateTime.new(2016, 11, 01, 21, 53, 3)
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.warnings).to be_empty
    end

    it "chooses correct main value with DateCreated + TimeCreated (String)" do
      hash = { 'DateTimeOriginal' => '', 'SubSecTimeOriginal' => '123', 'DateCreated' => '2005:05:05', 'TimeCreated' => '05:05:05+05:00' }
      allow(mhash).to receive(:[]) { |tag| hash[tag] }

      expect(subject.raw_values['DateTimeOriginal']).to be_empty
      expect(subject.raw_values['SubSecTimeOriginal']).to eq '123'
      expect(subject.raw_values['DateCreated']).to eq '2005:05:05'
      expect(subject.raw_values['TimeCreated']).to eq '05:05:05+05:00'
      expect(subject.value).to eq DateTime.new(2005, 5, 5, 5, 5, 5, '+05:00')
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.warnings).to be_empty
    end

    it "avoids execptions when parsing incorrect date from 2 part strings" do
      hash = { 'DateTimeOriginal' => '', 'SubSecTimeOriginal' => '123', 'DateCreated' => 'unknown date', 'TimeCreated' => 'time' }
      allow(mhash).to receive(:[]) { |tag| hash[tag] }

      expect(subject.raw_values['DateTimeOriginal']).to be_empty
      expect(subject.raw_values['SubSecTimeOriginal']).to eq '123'
      expect(subject.raw_values['DateCreated']).to eq 'unknown date'
      expect(subject.raw_values['TimeCreated']).to eq 'time'
      expect(subject.value).to be_empty
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.warnings).to be_empty
    end
  end
end
