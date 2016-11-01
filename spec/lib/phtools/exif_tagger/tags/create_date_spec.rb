#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/create_date'
require 'date'

describe ExifTagger::Tag::CreateDate do
  let(:tag_id) { :create_date }
  let(:tag_name) { 'CreateDate' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { DateTime.new(2014, 8, 12, 21, 58, 55) }
  let(:val_orig) { { 'CreateDate' => DateTime.new(2014, 01, 21, 11, 5, 5), 'SubSecTimeDigitized' => 123, 'DigitalCreationDate' => '2005:05:05', 'DigitalCreationTime' => '05:05:05+05:00' } }
  let(:val_orig_empty) { { 'CreateDate' => '', 'DigitalCreationDate' => '', 'DigitalCreationTime' => nil } }

  let(:hash_ok) { { 'CreateDate' => DateTime.new(2014, 8, 12, 21, 58, 55), 'SubSecTimeDigitized' => 123, 'DigitalCreationDate' => '2005:05:05', 'DigitalCreationTime' => '05:05:05+05:00' } }
  let(:hash_last_is_empty) { { 'CreateDate' => DateTime.new(2014, 8, 12, 21, 58, 55), 'SubSecTimeDigitized' => 123, 'DigitalCreationDate' => '2005:05:05', 'DigitalCreationTime' => '' } }
  let(:hash_last_is_all_spaces) { { 'CreateDate' => DateTime.new(2014, 8, 12, 21, 58, 55), 'SubSecTimeDigitized' => 123, 'DigitalCreationDate' => '2005:05:05', 'DigitalCreationTime' => '  ' } }
  let(:hash_last_is_nil) { { 'CreateDate' => DateTime.new(2014, 8, 12, 21, 58, 55), 'SubSecTimeDigitized' => 123, 'DigitalCreationDate' => '2005:05:05', 'DigitalCreationTime' => nil } }
  let(:hash_with_nondefined) { { 'CreateDate' => DateTime.new(2014, 8, 12, 21, 58, 55), 'DigitalCreationTime' => '' } }
  let(:hash_with_all_bool) { { 'CreateDate' => false, 'SubSecTimeDigitized' => false, 'DigitalCreationDate' => true, 'DigitalCreationTime' => false } }
  let(:hash_with_all_empty) { { 'CreateDate' => '', 'SubSecTimeDigitized' => nil, 'DigitalCreationDate' => '', 'DigitalCreationTime' => '' } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:CreateDate=2014-08-12 21:58:55')
  end

  it 'does NOT generate write_script for EMPTY value' do
    tag = described_class.new('')
    expect(tag.to_write_script).not_to include('-MWG:CreateDate=')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) { '123456789012345678901234567890123' } # bytesize=33
  it_behaves_like 'any date-tag'

  it_behaves_like 'any tag who cares about previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'

  context 'when gets partially defined mini_exiftool hash' do
    subject { described_class.new(mhash) }
    it "chooses correct main value" do
      hash = { 'CreateDate' => '', 'SubSecTimeDigitized' => '123', 'DigitalCreationDate' => '2005:05:05', 'DigitalCreationTime' => '05:05:05+05:00' }
      allow(mhash).to receive(:[]) { |tag| hash[tag] }

      expect(subject.raw_values['CreateDate']).to be_empty
      expect(subject.raw_values['SubSecTimeDigitized']).to eq '123'
      expect(subject.raw_values['DigitalCreationDate']).to eq '2005:05:05'
      expect(subject.raw_values['DigitalCreationTime']).to eq '05:05:05+05:00'
      expect(subject.value).to eq DateTime.new(2005, 5, 5, 5, 5, 5, '+05:00')
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.warnings).to be_empty
    end
    it "avoids execptions when parsing incorrect date from 2 part strings" do
      hash = { 'CreateDate' => '', 'SubSecTimeDigitized' => '123', 'DigitalCreationDate' => 'unknown date', 'DigitalCreationTime' => 'time' }
      allow(mhash).to receive(:[]) { |tag| hash[tag] }

      expect(subject.raw_values['CreateDate']).to be_empty
      expect(subject.raw_values['SubSecTimeDigitized']).to eq '123'
      expect(subject.raw_values['DigitalCreationDate']).to eq 'unknown date'
      expect(subject.raw_values['DigitalCreationTime']).to eq 'time'
      expect(subject.value).to be_empty
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.warnings).to be_empty
    end
  end
end
