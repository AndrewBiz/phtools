#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/country_code'

describe ExifTagger::Tag::CountryCode do
  let(:tag_id) { :country_code }
  let(:tag_name) { 'CountryCode' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) { 'RU' }
  let(:val_orig) { { 'LocationShownCountryCode' => 'UA' } }
  let(:val_orig_empty) { { 'LocationShownCountryCode' => '' } }

  let(:hash_ok) { { 'LocationShownCountryCode' => 'RU' } }
  let(:hash_last_is_empty) { { 'LocationShownCountryCode' => '' } }
  let(:hash_last_is_all_spaces) { { 'LocationShownCountryCode' => '     ' } }
  let(:hash_last_is_nil) { { 'LocationShownCountryCode' => nil } }
  let(:hash_with_nondefined) { {} }
  let(:hash_with_all_bool) { { 'LocationShownCountryCode' => false } }
  let(:hash_with_all_empty) { { 'LocationShownCountryCode' => '' } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-XMP:LocationShownCountryCode=RU')
  end

  it 'does NOT generate write_script for EMPTY value' do
    tag = described_class.new('')
    expect(tag.to_write_script).not_to include('-XMP:LocationShownCountryCode=')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) { '123456789012345678901234567890123' } # bytesize=33
  it_behaves_like 'any string tag'

  it_behaves_like 'any tag with previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'
end
