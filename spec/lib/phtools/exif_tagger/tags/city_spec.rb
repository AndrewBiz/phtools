#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/city'

describe ExifTagger::Tag::City do
  let(:tag_id) { :city }
  let(:tag_name) { 'City' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { 'Moscow' }
  let(:val_orig) { { 'City' => 'Kiev' } }
  let(:val_orig_empty) { { 'City' => '', 'LocationShownCity' => nil } }

  let(:hash_ok) { { 'City' => 'Moscow', 'LocationShownCity' => 'Москва' } }
  let(:hash_last_is_empty) { { 'City' => 'Moscow', 'LocationShownCity' => '' } }
  let(:hash_last_is_all_spaces) { { 'City' => ' Moscow ', 'LocationShownCity' => '      ' } }
  let(:hash_last_is_nil) { { 'City' => 'Moscow', 'LocationShownCity' => nil } }
  let(:hash_with_nondefined) { { 'City' => 'Moscow' } }
  let(:hash_with_all_bool) { { 'City' => true, 'LocationShownCity' => false } }
  let(:hash_with_all_empty) { { 'City' => '', 'LocationShownCity' => nil } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:City=Moscow')
  end

  it_behaves_like 'any tag'
  it_behaves_like 'any tag with previous value'

  let(:val_nok_size) { '123456789012345678901234567890123' } # bytesize=33
  it_behaves_like 'any string_tag'

  it_behaves_like 'any tag with MiniExiftool hash input'

  context 'when gets partially defined mini_exiftool hash as initial value' do
    subject { described_class.new(mhash) }
    it "chooses correct main value" do
      hash = { 'City' => nil, 'LocationShownCity' => 'Москва' }
      allow(mhash).to receive(:[]) { |tag| hash[tag] }

      expect(subject.raw_values['City']).to be_empty
      expect(subject.raw_values['LocationShownCity']).to eq 'Москва'
      expect(subject.value).to eq 'Москва'
      expect(subject.to_s).to include('Москва')
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.warnings).to be_empty
    end
  end
end
