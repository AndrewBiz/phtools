#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger/tags/gps_created'

describe ExifTagger::Tag::GpsCreated do
  let(:tag_id) { :gps_created }
  let(:tag_name) { 'GpsCreated' }

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }
  let(:tag) { described_class.new(val_ok) }

  let(:val_ok) do
    { gps_latitude: '55 36 31.49',
      gps_latitude_ref: 'N',
      gps_longitude: '37 43 28.27',
      gps_longitude_ref: 'E',
      gps_altitude: '170.0',
      gps_altitude_ref: 'Above Sea Level' }
  end
  let(:val_with_unknown_key) do
    { gps_latitudeXXX: '55 36 31.49',
      gps_latitude_ref: 'N',
      gps_longitude: '37 43 28.27',
      gps_longitude_ref: 'E',
      gps_altitude: '170.0',
      gps_altitude_ref: 'Above Sea Level' }
  end
  let(:val_with_missed_key) do
    { gps_latitude: '55 36 31.49',
      gps_latitude_ref: 'N',
      gps_longitude: '37 43 28.27',
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

  let(:hash_ok) { { 'GPSPosition' => 'position', 'GPSLatitude' => '55 36 31.49', 'GPSLatitudeRef' => 'N', 'GPSLongitude' => '37 43 28.27', 'GPSLongitudeRef' => 'E', 'GPSAltitude' => '170.0', 'GPSAltitudeRef' => 'Above Sea Level' } }
  let(:hash_last_is_empty) { { 'GPSPosition' => 'position', 'GPSLatitude' => '55 36 31.49', 'GPSLatitudeRef' => 'N', 'GPSLongitude' => '37 43 28.27', 'GPSLongitudeRef' => 'E', 'GPSAltitude' => '170.0', 'GPSAltitudeRef' => '' } }
  let(:hash_last_is_all_spaces) { { 'GPSPosition' => 'position', 'GPSLatitude' => '55 36 31.49', 'GPSLatitudeRef' => 'N', 'GPSLongitude' => '37 43 28.27', 'GPSLongitudeRef' => 'E', 'GPSAltitude' => '170.0', 'GPSAltitudeRef' => '      ' } }
  let(:hash_last_is_nil) { { 'GPSPosition' => 'position', 'GPSLatitude' => '55 36 31.49', 'GPSLatitudeRef' => 'N', 'GPSLongitude' => '37 43 28.27', 'GPSLongitudeRef' => 'E', 'GPSAltitude' => '170.0', 'GPSAltitudeRef' => nil } }
  let(:hash_with_nondefined) { { 'GPSPosition' => 'position', 'GPSLatitudeRef' => 'N', 'GPSLongitude' => '37 43 28.27', 'GPSLongitudeRef' => 'E', 'GPSAltitudeRef' => 'Above Sea Level' } }
  let(:hash_with_all_bool) { { 'GPSPosition' => true, 'GPSLatitude' => false, 'GPSLatitudeRef' => false, 'GPSLongitude' => false, 'GPSLongitudeRef' => true, 'GPSAltitude' => false, 'GPSAltitudeRef' => false } }
  let(:hash_with_all_empty) { { 'GPSPosition' => '', 'GPSLatitude' => '', 'GPSLatitudeRef' => '', 'GPSLongitude' => '', 'GPSLongitudeRef' => '', 'GPSAltitude' => '', 'GPSAltitudeRef' => '' } }

  it 'generates write_script for exiftool' do
    expect(tag.to_write_script)
    expect(tag.write_script_lines).to include('-GPSLatitude="55 36 31.49"')
    expect(tag.write_script_lines).to include('-GPSLatitudeRef=N')
    expect(tag.write_script_lines).to include('-GPSLongitude="37 43 28.27"')
    expect(tag.write_script_lines).to include('-GPSLongitudeRef=E')
    expect(tag.write_script_lines).to include('-GPSAltitude=170.0')
    expect(tag.write_script_lines).to include('-GPSAltitudeRef=Above Sea Level')
  end

  it 'does NOT generate write_script for empty items' do
    tag = described_class.new({ gps_latitude: '', gps_latitude_ref: '', gps_longitude: '', gps_longitude_ref: '', gps_altitude: '', gps_altitude_ref: '' })
    expect(tag.to_write_script)
    expect(tag.write_script_lines.size).to eq 0
    expect(tag.write_script_lines).not_to include('-GPSLatitude=')
    expect(tag.write_script_lines).not_to include('-GPSLatitudeRef=')
    expect(tag.write_script_lines).not_to include('-GPSLongitude=')
    expect(tag.write_script_lines).not_to include('-GPSLongitudeRef=')
    expect(tag.write_script_lines).not_to include('-GPSAltitude=')
    expect(tag.write_script_lines).not_to include('-GPSAltitudeRef=')
  end

  it_behaves_like 'any tag'

  let(:val_nok_size) do
    { gps_latitude: '1234567890123456789012345678901212345678901234567890123456789012X',
      gps_latitude_ref: 'N',
      gps_longitude: '37 43 28.27',
      gps_longitude_ref: 'E',
      gps_altitude: '170.0',
      gps_altitude_ref: 'Above Sea Level' }
  end # size=65
  it_behaves_like 'any hash_of_strings tag'

  it_behaves_like 'any tag who cares about previous value'

  it_behaves_like 'any tag with MiniExiftool hash input'

  context 'when gets input value' do
    it 'converts all hash items to strings' do
      val_hash = { gps_latitude: Date.new(2016),
                   gps_latitude_ref: 'N',
                   gps_longitude: 37.43,
                   gps_longitude_ref: 'E',
                   gps_altitude: 180,
                   gps_altitude_ref: 'Above Sea Level' }
      val_array_normal = [ '2016-01-01', 'N', '37.43', 'E', '180', 'Above Sea Level' ]
      tag = described_class.new(val_hash)

      expect(tag.value.values).to match_array(val_array_normal)
      expect(tag).to be_valid
      expect(tag.errors).to be_empty
      expect(tag.value_invalid).to be_empty
    end

    it 'converts all-spaces items to EMPTY strings items' do
      val_hash = { gps_latitude: '            ',
                   gps_latitude_ref: 'N',
                   gps_longitude: '         ',
                   gps_longitude_ref: 'E',
                   gps_altitude: '       ',
                   gps_altitude_ref: 'Above Sea Level' }
      val_array_normal = [ '', 'N', '', 'E', '', 'Above Sea Level' ]
      tag = described_class.new(val_hash)

      expect(tag.value.values).to match_array(val_array_normal)
      expect(tag).to be_valid
      expect(tag.errors).to be_empty
      expect(tag.value_invalid).to be_empty
    end

    it 'finds errors in hash items' do
      val_nok = { gps_latitude: '55 36 31.49',
                  gps_latitude_ref: 'X',
                  gps_longitude: '37 43 28.27',
                  gps_longitude_ref: 'Y',
                  gps_altitude: '170.0',
                  gps_altitude_ref: 'Tralala' }
      tag = described_class.new(val_nok)

      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.value_invalid).to eql([val_nok])
      expect(tag.errors.inspect).to include("'gps_latitude_ref' should be")
      expect(tag.errors.inspect).to include("'gps_longitude_ref' should be")
      expect(tag.errors.inspect).to include("'gps_altitude_ref' should be")
      expect(tag.value).to be_empty
      expect(tag.to_write_script).to be_empty
    end

    it 'allows alternative values for hash items' do
      val_nok = { gps_latitude: '55 36 31.49',
                  gps_latitude_ref: 'North',
                  gps_longitude: '37 43 28.27',
                  gps_longitude_ref: 'East',
                  gps_altitude: '170.0',
                  gps_altitude_ref: '0' }
      tag = described_class.new(val_nok)

      expect(tag).to be_valid
      expect(tag.errors).to be_empty
      expect(tag.value_invalid).to be_empty
    end
  end
end
