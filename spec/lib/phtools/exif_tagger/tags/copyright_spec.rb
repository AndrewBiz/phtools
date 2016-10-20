#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/copyright'

describe ExifTagger::Tag::Copyright do
  let(:tag_id) { :copyright }
  let(:tag_name) { 'Copyright' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { '2016 (c) Andrew Bizyaev' }
  let(:val_orig) { { 'Copyright' => 'Shirli-Myrli' } }
  let(:val_orig_empty) { { 'Copyright' => '', 'CopyrightNotice' => '', 'Rights' => '' } }

  let(:hash_ok) { { 'Copyright' => '2016 (c) Andrew Bizyaev', 'CopyrightNotice' => 'CRN', 'Rights' => 'rights'} }
  let(:hash_last_is_empty) { { 'Copyright' => '2016 (c) Andrew Bizyaev', 'CopyrightNotice' => 'CRN', 'Rights' => ''} }
  let(:hash_last_is_all_spaces) { { 'Copyright' => '2016 (c) Andrew Bizyaev', 'CopyrightNotice' => 'CRN', 'Rights' => '        '} }
  let(:hash_last_is_nil) { { 'Copyright' => '2016 (c) Andrew Bizyaev', 'CopyrightNotice' => 'CRN', 'Rights' => nil} }
  let(:hash_with_nondefined) { { 'Copyright' => '2016 (c) Andrew Bizyaev', 'Rights' => 'rights'} }
  let(:hash_with_all_bool) { { 'Copyright' => true, 'CopyrightNotice' => true, 'Rights' => false} }
  let(:hash_with_all_empty) { { 'Copyright' => '', 'CopyrightNotice' => '', 'Rights' => ''} }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:Copyright=2016 (c) Andrew Bizyaev')
  end

  it 'does NOT generate write_script for EMPTY value' do
    tag = described_class.new('')
    expect(tag.to_write_script).not_to include('-MWG:Copyright=')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) { '123456789012345678901234567890123456789012345678901234567890123412345678901234567890123456789012345678901234567890123456789012345' } # bytesize=129
  it_behaves_like 'any string tag'

  it_behaves_like 'any tag with previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'

  context 'when gets partially defined mini_exiftool hash' do
    subject { described_class.new(mhash) }
    it "chooses correct main value = 1st when 1 and 3 exist" do
      hash = { 'Copyright' => 'copyright', 'CopyrightNotice' => '', 'Rights' => 'rights' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.value).to eq 'copyright'
      expect(subject.warnings).to be_empty
    end

    it "chooses correct main value = 2nd when 2 and 3 exist" do
      hash = { 'Copyright' => '', 'CopyrightNotice' => 'cpn', 'Rights' => 'rights' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.value).to eq 'cpn'
      expect(subject.warnings).to be_empty
    end

    it "chooses correct main value = 3rd when only 3 exists" do
      hash = { 'Copyright' => '', 'CopyrightNotice' => '', 'Rights' => 'rights' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.value).to eq 'rights'
      expect(subject.warnings).to be_empty
    end
  end
end
