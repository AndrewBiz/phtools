#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/keywords'

describe ExifTagger::Tag::Keywords do
  let(:tag_id) { :keywords }
  let(:tag_name) { 'Keywords' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { %w(aaa bbb ййй ццц) }
  let(:val_orig) { { 'Keywords' => %w(original keyword) } }
  let(:val_orig_empty) { { 'Keywords' => '', 'Subject' => [''] } }

  let(:hash_ok) { { 'Keywords' => %w(aaa bbb ййй ццц), 'Subject' => ['s1', 's2'] } }
  let(:hash_last_is_empty) { { 'Keywords' => %w(aaa bbb ййй ццц), 'Subject' => '' } }
  let(:hash_last_is_all_spaces) { { 'Keywords' => %w(aaa bbb ййй ццц), 'Subject' => '   ' } }
  let(:hash_last_is_nil) { { 'Keywords' => %w(aaa bbb ййй ццц), 'Subject' => nil } }
  let(:hash_with_nondefined) { { 'Keywords' => %w(aaa bbb ййй ццц) } }
  let(:hash_with_all_bool) { { 'Keywords' => false, 'Subject' => true } }
  let(:hash_with_all_empty) { { 'Keywords' => '', 'Subject' => '' } }


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

  it 'does NOT generate write_script for empty items' do
    tag = described_class.new(['', nil, ''])
    expect(tag.to_write_script)
    expect(tag.write_script_lines.size).to eq 0
    expect(tag.write_script_lines).not_to include('-MWG:Keywords-=')
    expect(tag.write_script_lines).not_to include('-MWG:Keywords+=')
  end

  it 'does NOT generate write_script for empty item only' do
    tag = described_class.new(['', 'Andrew'])
    expect(tag.to_write_script)
    expect(tag.write_script_lines.size).to eq 2
    expect(tag.write_script_lines).not_to include('-MWG:Keywords-=')
    expect(tag.write_script_lines).not_to include('-MWG:Keywords+=')
    expect(tag.write_script_lines).to include('-MWG:Keywords-=Andrew')
    expect(tag.write_script_lines).to include('-MWG:Keywords+=Andrew')
  end

  it_behaves_like 'any tag'

  let(:val_ok_size) do
    val = []
    val << 'just test string' # bytesize=16
    val << '1234567890123456789012345678901234567890123456789012345678901234' # bytesize=64
    val << 'абвгдеёжзийклмнопрстуфхцчшщъыьэю' # bytesize=64
  end

  let(:val_nok_size) do
    val = []
    val << '12345678901234567890123456789012345678901234567890123456789012345' # bytesize=65
    val << 'абвгдеёжзийклмнопрстуфхцчшщъыьэюZ' # bytesize=65
    val << 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя' # bytesize=66
  end

  it_behaves_like 'any array_of_strings tag'

  context 'when gets both new and previous value' do
    let(:previous_value) { described_class.new(mhash) }
    let(:tag) { described_class.new(val_ok, previous_value) }

    it "ignores previous value of wrong type (!= tag.class)" do
      tag = described_class.new(val_ok, 'string_class')

      expect(tag.previous).to be_nil
      expect(tag.value).to eq(val_ok)
      expect(tag.raw_values).to be_empty
      expect(tag.to_s).to include(val_ok.to_s)
      expect(tag).to be_valid
      expect(tag.errors).to be_empty
      expect(tag.value_invalid).to be_empty
      expect(tag.warnings).to be_empty
      expect(tag.warnings.inspect).not_to include('has original value:')
    end

    it "generates no warnings if previous.raw_values are empty" do
      allow(mhash).to receive(:[]) { |tag| val_orig_empty[tag] }

      expect(tag.previous).not_to be_nil
      expect(tag.previous.class).to eq(described_class)
      expect(tag.value).to eq(val_ok)
      expect(tag.raw_values).to be_empty
      expect(tag.to_s).to include(val_ok.to_s)
      expect(tag).to be_valid
      expect(tag.errors).to be_empty
      expect(tag.value_invalid).to be_empty
      expect(tag.warnings).to be_empty
      expect(tag.warnings.inspect).not_to include('has original value:')
    end

    it "generates NO warnings if previous.raw_values are not empty" do
      allow(mhash).to receive(:[]) { |tag| val_orig[tag] }

      expect(tag.previous).not_to be_nil
      expect(tag.previous.class).to eq(described_class)
      expect(tag.previous.raw_values).not_to be_empty
      expect(tag.value).to eq(val_ok)
      expect(tag.raw_values).to be_empty
      expect(tag).to be_valid
      expect(tag.errors).to be_empty
      expect(tag.value_invalid).to be_empty
      expect(tag.warnings).to be_empty
      expect(tag.warnings.inspect).not_to include('has original value:')
    end
  end

  it_behaves_like 'any tag with MiniExiftool hash input'

  context 'when gets partially defined mini_exiftool hash' do
    subject { described_class.new(mhash) }

    context 'when input values have >1 items in arrays' do
      it "chooses correct main value = 2nd when only 2 exists" do
        hash = { 'Keywords' => nil, 'Subject' => ['s1', 's2'] }
        allow(mhash).to receive(:[]) { |t| hash[t] }

        expect(subject.value).to eq ['s1', 's2']
        expect(subject).to be_valid
        expect(subject.errors).to be_empty
        expect(subject.value_invalid).to be_empty
        expect(subject.warnings).to be_empty
      end
    end

    context 'when input values have 1 item (string)' do
      it "chooses correct main value = 2nd when only 2 exists" do
        hash = { 'Keywords' => nil, 'Subject' => 's1' }
        allow(mhash).to receive(:[]) { |t| hash[t] }

        expect(subject.value).to eq ['s1']
        expect(subject).to be_valid
        expect(subject.errors).to be_empty
        expect(subject.value_invalid).to be_empty
        expect(subject.warnings).to be_empty
      end
    end
  end
end
