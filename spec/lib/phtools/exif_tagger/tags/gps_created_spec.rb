#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/gps_created'

describe ExifTagger::Tag::GpsCreated do
  let(:tag_id) { :gps_created }
  let(:tag_name) { 'GpsCreated' }

  let(:val_ok) do
    { gps_latitude: '55 36 31.49',
      gps_latitude_ref: 'N',
      gps_longitude: '37 43 28.27',
      gps_longitude_ref: 'E',
      gps_altitude: '170.0',
      gps_altitude_ref: 'Above Sea Level' }
  end
  let(:val_orig) { { 'GPSLatitude' => '20 20 00', 'GPSLongitude' => '20 20 00' } }
  let(:val_orig_empty) do
    { 'GPSPosition' => '',
      'GPSLatitude' => '',
      'GPSLatitudeRef' => '',
      'GPSLongitude' => '',
      'GPSLongitudeRef' => '',
      'GPSAltitude' => '',
      'GPSAltitudeRef' => '' }
  end
  let(:tag) { described_class.new(val_ok) }

  it_behaves_like 'any tag'

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script).to include('-GPSLatitude="55 36 31.49"')
    expect(tag.to_write_script).to include('-GPSLatitudeRef=N')
    expect(tag.to_write_script).to include('-GPSLongitude="37 43 28.27"')
    expect(tag.to_write_script).to include('-GPSLongitudeRef=E')
    expect(tag.to_write_script).to include('-GPSAltitude=170.0')
    expect(tag.to_write_script).to include('-GPSAltitudeRef=Above Sea Level')
  end

  it_behaves_like 'any paranoid tag'

  context 'when the original value exists' do
    it 'considers empty strings as a no-value' do
      tag.check_for_warnings(original_values: val_orig_empty)
      expect(tag.warnings).to be_empty
      expect(tag.warnings.inspect).not_to include('has original value:')
    end
  end

  context 'when gets invalid input' do
    context 'with unknown key' do
      val_nok = { gps_latitude: '55 36 31.49',
                  gps_unknown: 'N',
                  gps_longitude: '37 43 28.27',
                  gps_longitude_ref: 'E',
                  gps_altitude: '170.0',
                  gps_altitude_ref: 'Above Sea Level' }
      subject { described_class.new(val_nok) }
      its(:value) { should be_empty }
      it { should_not be_valid }
      its(:value_invalid) { should_not be_empty }
      its(:value_invalid) { should eql([val_nok]) }
      its('errors.inspect') { should include("'gps_unknown' is unknown") }
      its(:to_write_script) { should be_empty }
    end
    context 'when mandatory keys are missed' do
      val_nok = { gps_latitude: '55 36 31.49',
                  gps_longitude: '37 43 28.27',
                  gps_altitude: '170.0',
                  gps_altitude_ref: 'Above Sea Level' }
      subject { described_class.new(val_nok) }
      its(:value) { should be_empty }
      it { should_not be_valid }
      its(:value_invalid) { should_not be_empty }
      its(:value_invalid) { should eql([val_nok]) }
      its('errors.inspect') { should include("'gps_latitude_ref' is missed") }
      its('errors.inspect') { should include("'gps_longitude_ref' is missed") }
      its(:to_write_script) { should be_empty }
    end
    context 'with wrong key values' do
      val_nok = { gps_latitude: '55 36 31.49',
                  gps_latitude_ref: 'X',
                  gps_longitude: '37 43 28.27',
                  gps_longitude_ref: 'Y',
                  gps_altitude: '170.0',
                  gps_altitude_ref: 'Tralala' }
      subject { described_class.new(val_nok) }
      its(:value) { should be_empty }
      it { should_not be_valid }
      its(:value_invalid) { should_not be_empty }
      its(:value_invalid) { should eql([val_nok]) }
      its('errors.inspect') { should include("'gps_latitude_ref' should be") }
      its('errors.inspect') { should include("'gps_longitude_ref' should be") }
      its('errors.inspect') { should include("'gps_altitude_ref' should be") }
      its(:to_write_script) { should be_empty }
    end
  end
end
