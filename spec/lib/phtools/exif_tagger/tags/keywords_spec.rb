#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/keywords'

describe ExifTagger::Tag::Keywords do
  let(:val_ok) { %w(aaa bbb ййй ццц) }
  let(:val_orig) { { 'Keywords' => %w(original keyword) } }
  let(:tag) { described_class.new(val_ok) }

  it_behaves_like 'any tag'

  it 'knows it\'s ID' do
    expect(tag.tag_id).to be :keywords
    expect(tag.tag_name).to eq 'Keywords'
  end

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:Keywords-=aaa')
    expect(tag.to_write_script).to include('-MWG:Keywords+=aaa')
    expect(tag.to_write_script).to include('-MWG:Keywords-=bbb')
    expect(tag.to_write_script).to include('-MWG:Keywords+=bbb')
    expect(tag.to_write_script).to include('-MWG:Keywords-=ййй')
    expect(tag.to_write_script).to include('-MWG:Keywords+=ййй')
    expect(tag.to_write_script).to include('-MWG:Keywords-=ццц')
    expect(tag.to_write_script).to include('-MWG:Keywords+=ццц')
  end

  context 'when the original value (read by mini_exiftool) exists -' do
    it 'generates NO warnings' do
      tag.check_for_warnings(original_values: val_orig)
      expect(tag.warnings).to be_empty
    end
    it 'generates write_script for exiftool' do
      tag.check_for_warnings(original_values: val_orig)
      expect(tag.to_write_script).to include('-MWG:Keywords-=aaa')
      expect(tag.to_write_script).to include('-MWG:Keywords+=aaa')
      expect(tag.to_write_script).to include('-MWG:Keywords-=bbb')
      expect(tag.to_write_script).to include('-MWG:Keywords+=bbb')
      expect(tag.to_write_script).to include('-MWG:Keywords-=ййй')
      expect(tag.to_write_script).to include('-MWG:Keywords+=ййй')
      expect(tag.to_write_script).to include('-MWG:Keywords-=ццц')
      expect(tag.to_write_script).to include('-MWG:Keywords+=ццц')
      expect(tag.to_write_script).not_to include('# -MWG:Keywords-=aaa')
      expect(tag.to_write_script).not_to include('# -MWG:Keywords+=aaa')
      expect(tag.to_write_script).not_to include('# -MWG:Keywords-=bbb')
      expect(tag.to_write_script).not_to include('# -MWG:Keywords+=bbb')
      expect(tag.to_write_script).not_to include('# -MWG:Keywords-=ййй')
      expect(tag.to_write_script).not_to include('# -MWG:Keywords+=ййй')
      expect(tag.to_write_script).not_to include('# -MWG:Keywords-=ццц')
      expect(tag.to_write_script).not_to include('# -MWG:Keywords+=ццц')
      expect(tag.to_write_script).not_to match(/# WARNING: ([\w]*) has original value:/)
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
    val_ok << '1234567890123456789012345678901234567890123456789012345678901234' # bytesize=64
    val_ok << 'абвгдеёжзийклмнопрстуфхцчшщъыьэю' # bytesize=64
    val_nok = []
    val_nok << '12345678901234567890123456789012345678901234567890123456789012345' # bytesize=65
    val_nok << 'абвгдеёжзийклмнопрстуфхцчшщъыьэюZ' # bytesize=65
    val_nok << 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя' # bytesize=66

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
