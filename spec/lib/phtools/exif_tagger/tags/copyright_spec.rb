#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/copyright'

describe ExifTagger::Tag::Copyright do
  let(:tag_id) { :copyright }
  let(:tag_name) { 'Copyright' }

  let(:val_ok) { '2014 (c) Andrew Bizyaev' }
  let(:val_orig) { { 'Copyright' => 'Shirli-Myrli' } }
  let(:val_orig_empty) { { 'Copyright' => '', 'CopyrightNotice' => '', 'Rights' => '' } }
  let(:tag) { described_class.new(val_ok) }

  it_behaves_like 'any tag'

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-MWG:Copyright=2014 (c) Andrew Bizyaev')
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
    val_nok = '123456789012345678901234567890123456789012345678901234567890123412345678901234567890123456789012345678901234567890123456789012345' # bytesize=129
    subject { described_class.new(val_nok) }
    its(:value) { should be_empty }
    it { should_not be_valid }
    its(:value_invalid) { should_not be_empty }
    its(:value_invalid) { should match_array([val_nok]) }
    its('errors.inspect') { should include("'#{val_nok}'") }
    its(:to_write_script) { should be_empty }
  end
end
