#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/collections'

describe ExifTagger::Tag::Collections do
  let(:tag_id) { :collections }
  let(:tag_name) { 'Collections' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { { collection_name: 'Collection Name', collection_uri: 'www.abc.net' } }
  let(:val_with_unknown_key) { { collection_name_wrong: 'Collection Name', collection_uri: 'www.abc.net' } }
  let(:val_with_missed_key) { { collection_name: 'Collection Name' } }

  let(:val_orig) { { 'CollectionName' => 'tralala', 'CollectionURI' => 'trululu' } }
  let(:val_orig_empty) { { 'CollectionName' => '', 'CollectionURI' => '' } }

  let(:hash_ok) { { 'CollectionName' => 'Collection Name', 'CollectionURI' => 'www.abc.net' } }
  let(:hash_last_is_empty) { { 'CollectionName' => 'Collection Name', 'CollectionURI' => '' } }
  let(:hash_last_is_all_spaces) { { 'CollectionName' => 'Collection Name', 'CollectionURI' => '' } }
  let(:hash_last_is_nil) { { 'CollectionName' => 'Collection Name', 'CollectionURI' => nil } }
  let(:hash_with_nondefined) { { 'CollectionURI' => '' } }
  let(:hash_with_all_bool) { { 'CollectionName' => true, 'CollectionURI' => false } }
  let(:hash_with_all_empty) { { 'CollectionName' => '', 'CollectionURI' => '' } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-XMP-mwg-coll:Collections-={CollectionName=Collection Name, CollectionURI=www.abc.net}')
    expect(tag.to_write_script).to include('-XMP-mwg-coll:Collections+={CollectionName=Collection Name, CollectionURI=www.abc.net}')
  end

  it 'does NOT generate write_script for empty items' do
    tag = described_class.new({ collection_name: '', collection_uri: '' })
    expect(tag.to_write_script)
    expect(tag.write_script_lines.size).to eq 0
    expect(tag.write_script_lines).not_to include('-XMP-mwg-coll:Collections-=')
    expect(tag.write_script_lines).not_to include('-XMP-mwg-coll:Collections+=')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) { { collection_name: '1234567890123456789012345678901212345678901234567890123456789012X', collection_uri: 'www.abc.net' } } # size=65
  it_behaves_like 'any hash_of_strings tag'

  it_behaves_like 'any tag who cares about previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'

  context 'when gets mini_exiftool hash' do
    subject { described_class.new(mhash) }

    example "with simple String items" do
      hash = { 'CollectionName' => 'name', 'CollectionURI' => 'uri' }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject.value).to eq({ collection_name: 'name', collection_uri: 'uri' })
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.warnings).to be_empty
    end

    example "with Array items" do
      hash = { 'CollectionName' => ['name1', 'name2'], 'CollectionURI' => ['uri1', 'uri2'] }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject.value).to eq({ collection_name: 'name1', collection_uri: 'uri1' })
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.warnings).to be_empty
    end

    example "with mixed Array and String items" do
      hash = { 'CollectionName' => 'name', 'CollectionURI' => ['uri1', 'uri2'] }
      allow(mhash).to receive(:[]) { |t| hash[t] }

      expect(subject.value).to eq({ collection_name: 'name', collection_uri: 'uri1' })
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.warnings).to be_empty
    end
  end
end
