#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/city'

describe ExifTagger::Tag::City do
  let(:val_ok) { 'Moscow' }
  let(:val_orig) { { 'City' => 'Kiev' } }
  let(:val_orig_empty) { { 'City' => '', 'LocationShownCity' => '' } }
  let(:tag) { described_class.new(val_ok) }

  let(:val_mhash_ok) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:mhash_ok) { { 'City' => 'Moscow', 'LocationShownCity' => 'Москва' } }
  before(:example) do
    allow(val_mhash_ok).to receive(:[]) { |tag_id| mhash_ok[tag_id] }
  end

  it_behaves_like 'any tag'

  it 'knows it\'s ID' do
    expect(tag.tag_id).to be :city
    expect(tag.tag_name).to eq 'City'
  end

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:City=Moscow')
  end

  it_behaves_like 'any paranoid tag'

  context 'when the original value exists' do
    it 'considers empty strings as a no-value' do
      tag.check_for_warnings(original_values: val_orig_empty)
      expect(tag.warnings).to be_empty
      expect(tag.warnings.inspect).not_to include('has original value:')
    end
  end

  context 'when gets invalid value' do
    val_nok = '123456789012345678901234567890123'# bytesize=33
    subject { described_class.new(val_nok) }
    its(:value) { should be_empty }
    it { should_not be_valid }
    its(:value_invalid) { should_not be_empty }
    its(:value_invalid) { should match_array([val_nok]) }
    its('errors.inspect') { should include("#{val_nok}") }
    its(:to_write_script) { should be_empty }
  end

  # TODO move to any tag
  context 'when gets correct mini_exiftool hash as initial value' do
    subject { described_class.new(val_mhash_ok) }

    it "works well with its test-double" do
      expect(val_mhash_ok.class).to eq MiniExiftool
      mhash_ok.each do |tag, value|
        expect(val_mhash_ok[tag]).to eq value
      end
    end

    it "accepts input MiniExiftool hash" do
      expect(subject.value).to eq val_ok
      expect(subject.to_s).to include(val_ok.to_s)
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.warnings).to be_empty
    end

    it "keeps raw_values" do
      mhash_ok.each do |tag, value|
        expect(subject.raw_values[tag]).to eq value
      end
    end
  end


end
