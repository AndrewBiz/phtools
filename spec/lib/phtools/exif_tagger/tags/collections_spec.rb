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
  let(:val_orig) { { 'CollectionName' => 'tralala', 'CollectionURI' => 'trululu' } }
  let(:val_orig_empty) { { 'CollectionName' => '', 'CollectionURI' => '' } }

  let(:hash_ok) {}
  let(:hash_last_is_empty) {}
  let(:hash_last_is_all_spaces) {}
  let(:hash_last_is_nil) {}
  let(:hash_with_nondefined) {}
  let(:hash_with_all_bool) {}
  let(:hash_with_all_empty) {}

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

  it_behaves_like 'any hash_of_strings tag'

  # it_behaves_like 'any tag who cares about previous value'
  #
  # it_behaves_like 'any tag with MiniExiftool hash input'

  context 'when gets invalid input' do
    context 'with unknown key' do
      val_nok = { coll_name_wrong: 'xyz', collection_uri: 'www.xyz.com' }
      subject { described_class.new(val_nok) }
      its(:value) { should be_empty }
      it { should_not be_valid }
      its(:value_invalid) { should_not be_empty }
      its(:value_invalid) { should eql([val_nok]) }
      its('errors.inspect') { should include("'coll_name_wrong' is unknown") }
      its(:to_write_script) { should be_empty }
    end
    context 'when mandatory keys are missed' do
      val_nok = { collection_uri: 'www.xyz.com' }
      subject { described_class.new(val_nok) }
      its(:value) { should be_empty }
      it { should_not be_valid }
      its(:value_invalid) { should_not be_empty }
      its(:value_invalid) { should eql([val_nok]) }
      its('errors.inspect') { should include("'collection_name' is missed") }
      its(:to_write_script) { should be_empty }
    end
  end
end
