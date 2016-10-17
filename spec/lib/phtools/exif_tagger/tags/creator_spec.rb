#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/creator'

describe ExifTagger::Tag::Creator do
  let(:tag_id) { :creator }
  let(:tag_name) { 'Creator' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { %w(Andrew Natalia) }
  let(:val_orig) { { 'Creator' => ['Dima', 'Polya'] } }
  let(:val_orig_empty) { { 'Creator' => [''], 'Artist' => '', 'By-line' => [''] } }

  # let(:hash_ok) { { 'City' => 'Moscow', 'LocationShownCity' => 'Москва' } }
  # let(:hash_last_is_empty) { { 'City' => 'Moscow', 'LocationShownCity' => '' } }
  # let(:hash_last_is_all_spaces) { { 'City' => ' Moscow ', 'LocationShownCity' => '      ' } }
  # let(:hash_last_is_nil) { { 'City' => 'Moscow', 'LocationShownCity' => nil } }
  # let(:hash_with_nondefined) { { 'City' => 'Moscow' } }
  # let(:hash_with_all_bool) { { 'City' => true, 'LocationShownCity' => false } }
  # let(:hash_with_all_empty) { { 'City' => '', 'LocationShownCity' => nil } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:Creator-=Andrew')
    expect(tag.to_write_script).to include('-MWG:Creator+=Andrew')
    expect(tag.to_write_script).to include('-MWG:Creator-=Natalia')
    expect(tag.to_write_script).to include('-MWG:Creator+=Natalia')
  end

  it 'does NOT generate write_script for empty items' do
    tag = described_class.new(['', nil, ''])
    expect(tag.to_write_script)
    expect(tag.write_script_lines.size).to eq 0
    expect(tag.write_script_lines).not_to include('-MWG:Creator-=')
    expect(tag.write_script_lines).not_to include('-MWG:Creator+=')
  end

  it 'does NOT generate write_script for empty item only' do
    tag = described_class.new(['', 'Andrew'])
    expect(tag.to_write_script)
    expect(tag.write_script_lines.size).to eq 2
    expect(tag.write_script_lines).not_to include('-MWG:Creator-=')
    expect(tag.write_script_lines).not_to include('-MWG:Creator+=')
    expect(tag.write_script_lines).to include('-MWG:Creator-=Andrew')
    expect(tag.write_script_lines).to include('-MWG:Creator+=Andrew')
  end

  it_behaves_like 'any tag'

  it_behaves_like 'any array_of_strings tag'

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

  # it_behaves_like 'any tag with previous value'
  #
  # it_behaves_like 'any tag with MiniExiftool hash input'
  #
  # context 'when gets partially defined mini_exiftool hash as initial value' do
  #   subject { described_class.new(mhash) }
  #   it "chooses correct main value" do
  #     hash = { 'City' => nil, 'LocationShownCity' => 'Москва' }
  #     allow(mhash).to receive(:[]) { |tag| hash[tag] }
  #
  #     expect(subject.raw_values['City']).to be_empty
  #     expect(subject.raw_values['LocationShownCity']).to eq 'Москва'
  #     expect(subject.value).to eq 'Москва'
  #     expect(subject.to_s).to include('Москва')
  #     expect(subject).to be_valid
  #     expect(subject.errors).to be_empty
  #     expect(subject.value_invalid).to be_empty
  #     expect(subject.warnings).to be_empty
  #   end
  # end
  # TODO: remove
  context 'when the original value exists' do
    it 'considers empty strings as a no-value' do
      tag.check_for_warnings(original_values: val_orig_empty)
      expect(tag.warnings).to be_empty
      expect(tag.warnings.inspect).not_to include('has original value:')
    end
  end

end
