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
  let(:val_orig_empty) { { 'Artist' => '', 'By-line' => [''], 'Creator' => ['']} }

  let(:hash_ok) { { 'Artist' => 'Andrew; Natalia', 'Creator' => ['Andrew-C', 'Natalia-C'], 'By-line' => ['Andrew-B', 'Natalia-B'] } }
  let(:hash_last_is_empty) { { 'Artist' => 'Andrew; Natalia', 'Creator' => ['Andrew-C', 'Natalia-C'], 'By-line' => '' } }
  let(:hash_last_is_all_spaces) { { 'Artist' => 'Andrew; Natalia', 'Creator' => ['Andrew-C', 'Natalia-C'], 'By-line' => '                        ' } }
  let(:hash_last_is_nil) { { 'Artist' => 'Andrew; Natalia', 'Creator' => ['Andrew-C', 'Natalia-C'], 'By-line' => nil } }
  let(:hash_with_nondefined) { { 'Artist' => 'Andrew; Natalia', 'By-line' => nil } }
  let(:hash_with_all_bool) { { 'Artist' => true, 'Creator' => false, 'By-line' => true } }
  let(:hash_with_all_empty) { { 'Artist' => '', 'Creator' => [], 'By-line' => nil } }

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

  let(:val_ok_size) do
    val = []
    val << 'just test string' # bytesize=16
    val << '12345678901234567890123456789012' # bytesize=32
    val << 'абвгдеёжзийклмно' # bytesize=32
  end

  let(:val_nok_size) do
    val = []
    val << '123456789012345678901234567890123' # bytesize=33
    val << 'абвгдеёжзийклмноZ' # bytesize=33
    val << 'абвгдеёжзийклмноп' # bytesize=34
  end

  it_behaves_like 'any array_of_strings tag'

  it_behaves_like 'any tag with previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'

  context 'when gets partially defined mini_exiftool hash' do
    subject { described_class.new(mhash) }

    context 'when input values have >1 items in arrays' do
      it "chooses correct main value = 1st when 1 and 3 exist" do
        hash = { 'Artist' => 'Andrew-A; Natalia-A', 'By-line' => [], 'Creator' => ['Andrew-C', 'Natalia-C'] }
        allow(mhash).to receive(:[]) { |t| hash[t] }

        expect(subject.value).to eq ['Andrew-A', 'Natalia-A']
        expect(subject).to be_valid
        expect(subject.errors).to be_empty
        expect(subject.value_invalid).to be_empty
        expect(subject.warnings).to be_empty
      end

      it "chooses correct main value = 2nd when 2 and 3 exist" do
        hash = { 'Artist' => '', 'By-line' => ['Andrew-B', 'Natalia-B'], 'Creator' => ['Andrew-C', 'Natalia-C'] }
        allow(mhash).to receive(:[]) { |t| hash[t] }

        expect(subject.value).to eq ['Andrew-B', 'Natalia-B']
        expect(subject).to be_valid
        expect(subject.errors).to be_empty
        expect(subject.value_invalid).to be_empty
        expect(subject.warnings).to be_empty
      end

      it "chooses correct main value = 3rd when only 3 exists" do
        hash = { 'Artist' => '', 'By-line' => [], 'Creator' => ['Andrew-C', 'Natalia-C'] }
        allow(mhash).to receive(:[]) { |t| hash[t] }

        expect(subject.value).to eq ['Andrew-C', 'Natalia-C']
        expect(subject).to be_valid
        expect(subject.errors).to be_empty
        expect(subject.value_invalid).to be_empty
        expect(subject.warnings).to be_empty
      end
    end

    context 'when input values have 1 item (string)' do
      it "chooses correct main value = 1st when 1 and 3 exist" do
        hash = { 'Artist' => 'Andrew-A', 'By-line' => [], 'Creator' => 'Andrew-C' }
        allow(mhash).to receive(:[]) { |t| hash[t] }

        expect(subject.value).to eq ['Andrew-A']
        expect(subject).to be_valid
        expect(subject.errors).to be_empty
        expect(subject.value_invalid).to be_empty
        expect(subject.warnings).to be_empty
      end

      it "chooses correct main value = 2nd when 2 and 3 exist" do
        hash = { 'Artist' => '', 'By-line' => 'Andrew-B', 'Creator' => 'Andrew-C' }
        allow(mhash).to receive(:[]) { |t| hash[t] }

        expect(subject.value).to eq ['Andrew-B']
        expect(subject).to be_valid
        expect(subject.errors).to be_empty
        expect(subject.value_invalid).to be_empty
        expect(subject.warnings).to be_empty
      end

      it "chooses correct main value = 3rd when only 3 exists" do
        hash = { 'Artist' => '', 'By-line' => [], 'Creator' => 'Andrew-C' }
        allow(mhash).to receive(:[]) { |t| hash[t] }

        expect(subject.value).to eq ['Andrew-C']
        expect(subject).to be_valid
        expect(subject.errors).to be_empty
        expect(subject.value_invalid).to be_empty
        expect(subject.warnings).to be_empty
      end
    end
  end
end
