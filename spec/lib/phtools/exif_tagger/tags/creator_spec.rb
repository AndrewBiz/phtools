#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/creator'

describe ExifTagger::Tag::Creator do
  let(:val_ok) { %w(Andrew Natalia) }
  let(:val_orig) { { 'Creator' => ['Dima', 'Polya'] } }
  let(:val_orig_empty) { { 'Creator' => [''], 'Artist' => '', 'By-line' => [''] } }
  let(:tag) { described_class.new(val_ok) }

  it_behaves_like 'any tag'

  it 'knows it\'s ID' do
    expect(tag.tag_id).to be :creator
    expect(tag.tag_name).to eq 'Creator'
  end

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:Creator-=Andrew')
    expect(tag.to_write_script).to include('-MWG:Creator+=Andrew')
    expect(tag.to_write_script).to include('-MWG:Creator-=Natalia')
    expect(tag.to_write_script).to include('-MWG:Creator+=Natalia')
  end

  it_behaves_like 'any paranoid tag'

  context 'when the original value exists' do
    it 'considers empty strings as a no-value' do
      tag.check_for_warnings(original_values: val_orig_empty)
      expect(tag.warnings).to be_empty
      expect(tag.warnings.inspect).not_to include('has original value:')
    end
  end

  context 'when gets a non-flat array as input' do
    val2 = ['www', ['eee', 'rrr'], 'ttt', [1, [2, 3]]]
    subject { described_class.new(val2) }
    val_normal = ['www', 'eee', 'rrr', 'ttt', '1', '2', '3']
    it 'converts the input to the flat array of strings' do
      expect(subject.value).to match_array(val_normal)
    end
    it { should be_valid }
    its(:errors) { should be_empty }
    its(:value_invalid) { should be_empty }
  end

  context 'when gets invalid value' do
    val_ok = []
    val_ok << 'just test string' # bytesize=16
    val_ok << '12345678901234567890123456789012' # bytesize=32
    val_ok << 'абвгдеёжзийклмно' # bytesize=32
    val_nok = []
    val_nok << '123456789012345678901234567890123' # bytesize=33
    val_nok << 'абвгдеёжзийклмноZ' # bytesize=33
    val_nok << 'абвгдеёжзийклмноп' # bytesize=34

    subject { described_class.new((val_ok + val_nok).sort) }
    its(:value) { should match_array(val_ok) }
    it { should_not be_valid }
    its(:value_invalid) { should_not be_empty }
    its(:value_invalid) { should match_array(val_nok) }

    val_nok.each do |i|
      its('errors.inspect') { should include("'#{i}'") }
      its(:to_write_script) { should_not include("#{i}") }
    end
    val_ok.each do |i|
      its('errors.inspect') { should_not include("'#{i}'") }
      its(:to_write_script) { should include("#{i}") }
    end
  end
end
