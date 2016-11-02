#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger'

describe ExifTagger::TagCollection do
  let(:mytags) { described_class.new }

  it 'saves the tag value' do
    val_array = %w(aaa bbb ааа ббб)
    mytags[:keywords] = val_array

    expect(mytags[:keywords]).to match_array(val_array)
  end

  it 'could stringify the tags' do
    val_array = %w(aaa bbb ааа ббб)
    mytags[:keywords] = val_array
    expect(mytags.to_s).to include(val_array.to_s)
  end

  it 'does not dublicate tags' do
    val1 = %w(aaa bbb)
    val2 = %w(ccc ddd)
    mytags[:keywords] = val1
    mytags[:keywords] = val2

    expect(mytags[:keywords]).not_to eql(val1)
    expect(mytags[:keywords]).to match_array(val2)
  end

  it 'deletes tag from collection' do
    val = %w(aaa bbb)
    mytags[:keywords] = val

    expect(mytags[:keywords]).to match_array(val)
    mytags.delete(:keywords)

    expect(mytags[:keywords]).to be_nil

    expect(mytags.item(:keywords)).to be_nil
  end

  it 'fails if unknown tag is used' do
    val = 'hahaha'
    expect { mytags[:unknown_tag] = val }.to raise_error(ExifTagger::UnknownTag)
  end

  it 'accepts and ignores nil value of the tag' do
    expect { mytags[:keywords] = nil }.not_to raise_error
    expect(mytags.item(:keywords)).to be_nil
  end

  it 'saves basic exif tags when they set one-by-one' do
    mytags[:creator] = %w(Andrey\ Bizyaev Matz)
    mytags[:copyright] = %(2014 \(c\) Andrey Bizyaev)
    mytags[:keywords] = %w(keyword1 keyword2)
    mytags[:world_region] = %(Europe)
    mytags[:country] = %(Russia)
    mytags[:country_code] = 'RU'
    mytags[:state] = %(State)
    mytags[:city] = %(Moscow)
    mytags[:location] = %(Pushkin street 1)
    gps = { gps_latitude: '55 36 31.49',
            gps_latitude_ref: 'N',
            gps_longitude: '37 43 28.27',
            gps_longitude_ref: 'E',
            gps_altitude: '170.0',
            gps_altitude_ref: 'Above Sea Level' }
    mytags[:gps_created] = gps
    coll = { collection_name: 'Collection Name',
             collection_uri: 'www.site.com' }
    mytags[:collections] = coll
    mytags[:image_unique_id] = '20140223-003748-0123'
    mytags[:coded_character_set] = 'UTF8'
    mytags[:modify_date] = 'now'

    expect(mytags[:creator]).to match_array(%w(Andrey\ Bizyaev Matz))
    expect(mytags[:copyright]).to include(%(2014 \(c\) Andrey Bizyaev))
    expect(mytags[:keywords]).to match_array(%w(keyword1 keyword2))
    expect(mytags[:world_region]).to include(%(Europe))
    expect(mytags[:country]).to include(%(Russia))
    expect(mytags[:country_code]).to include('RU')
    expect(mytags[:state]).to include(%(State))
    expect(mytags[:city]).to include(%(Moscow))
    expect(mytags[:location]).to include(%(Pushkin street 1))
    expect(mytags[:gps_created]).to eql(gps)
    expect(mytags[:collections]).to eql(coll)
    expect(mytags[:image_unique_id]).to include('20140223-003748-0123')
    expect(mytags[:coded_character_set]).to include('UTF8')
    expect(mytags[:modify_date]).to include('now')
    expect(mytags).to be_valid
    expect(mytags.error_message).to be_empty
  end

  it 'saves basic exif tags when they initialized via simple hash' do
    mytags = described_class.new(
      creator: %w(Andrey\ Bizyaev Matz),
      copyright: %(2014 \(c\) Andrey Bizyaev),
      keywords: %w(keyword1 keyword2),
      world_region: %(Europe),
      country: %(Russia),
      country_code: 'RU',
      state: %(State),
      city: %(Moscow),
      location: %(Pushkin street 1),
      gps_created: { gps_latitude: '55 36 31.49',
                     gps_latitude_ref: 'N',
                     gps_longitude: '37 43 28.27',
                     gps_longitude_ref: 'E',
                     gps_altitude: '170.0',
                     gps_altitude_ref: 'Above Sea Level' },
      collections: { collection_name: 'Collection Name',
                     collection_uri: 'www.site.com' },
      image_unique_id: '20140223-003748-0123',
      coded_character_set: 'UTF8',
      modify_date: 'now')

    expect(mytags[:creator]).to match_array(%w(Andrey\ Bizyaev Matz))
    expect(mytags[:copyright]).to include(%(2014 (c) Andrey Bizyaev))
    expect(mytags[:keywords]).to match_array(%w(keyword1 keyword2))
    expect(mytags[:world_region]).to include(%(Europe))
    expect(mytags[:country]).to include(%(Russia))
    expect(mytags[:country_code]).to include('RU')
    expect(mytags[:state]).to include(%(State))
    expect(mytags[:city]).to include(%(Moscow))
    expect(mytags[:location]).to include(%(Pushkin street 1))
    expect(mytags[:gps_created]).to eql(gps_latitude: '55 36 31.49',
                                        gps_latitude_ref: 'N',
                                        gps_longitude: '37 43 28.27',
                                        gps_longitude_ref: 'E',
                                        gps_altitude: '170.0',
                                        gps_altitude_ref: 'Above Sea Level')
    expect(mytags[:collections]).to eql(collection_name: 'Collection Name',
                                        collection_uri: 'www.site.com')
    expect(mytags[:image_unique_id]).to include('20140223-003748-0123')
    expect(mytags[:coded_character_set]).to include('UTF8')
    expect(mytags[:modify_date]).to include('now')
    expect(mytags).to be_valid
    expect(mytags.error_message).to be_empty
  end

  it 'saves basic exif tags when they initialized via another tag collection' do
    deftags = described_class.new(
      creator: %w(Andrey\ Bizyaev Matz),
      copyright: %(2014 \(c\) Andrey Bizyaev),
      keywords: %w(keyword1 keyword2),
      world_region: %(Europe),
      country: %(Russia),
      country_code: 'RU',
      state: %(State),
      city: %(Moscow),
      location: %(Pushkin street 1),
      gps_created: { gps_latitude: '55 36 31.49',
                     gps_latitude_ref: 'N',
                     gps_longitude: '37 43 28.27',
                     gps_longitude_ref: 'E',
                     gps_altitude: '170.0',
                     gps_altitude_ref: 'Above Sea Level' },
      collections: { collection_name: 'Collection Name',
                     collection_uri: 'www.site.com' },
      image_unique_id: '20140223-003748-0123',
      coded_character_set: 'UTF8',
      modify_date: 'now')

    mytags = described_class.new(deftags)

    expect(mytags[:creator]).to match_array(%w(Andrey\ Bizyaev Matz))
    expect(mytags[:copyright]).to include(%(2014 (c) Andrey Bizyaev))
    expect(mytags[:keywords]).to match_array(%w(keyword1 keyword2))
    expect(mytags[:world_region]).to include(%(Europe))
    expect(mytags[:country]).to include(%(Russia))
    expect(mytags[:country_code]).to include('RU')
    expect(mytags[:state]).to include(%(State))
    expect(mytags[:city]).to include(%(Moscow))
    expect(mytags[:location]).to include(%(Pushkin street 1))
    expect(mytags[:gps_created]).to eql(gps_latitude: '55 36 31.49',
                                        gps_latitude_ref: 'N',
                                        gps_longitude: '37 43 28.27',
                                        gps_longitude_ref: 'E',
                                        gps_altitude: '170.0',
                                        gps_altitude_ref: 'Above Sea Level')
    expect(mytags[:collections]).to eql(collection_name: 'Collection Name',
                                        collection_uri: 'www.site.com')
    expect(mytags[:image_unique_id]).to include('20140223-003748-0123')
    expect(mytags[:coded_character_set]).to include('UTF8')
    expect(mytags[:modify_date]).to include('now')

    expect(mytags[:creator]).to eq(deftags[:creator])
    expect(mytags[:copyright]).to eq(deftags[:copyright])
    expect(mytags[:keywords]).to eq(deftags[:keywords])
    expect(mytags[:world_region]).to eq(deftags[:world_region])
    expect(mytags[:country]).to eq(deftags[:country])
    expect(mytags[:country_code]).to eq(deftags[:country_code])
    expect(mytags[:state]).to eq(deftags[:state])
    expect(mytags[:city]).to eq(deftags[:city])
    expect(mytags[:location]).to eq(deftags[:location])
    expect(mytags[:location]).to eq(deftags[:location])
    expect(mytags[:collections]).to eq(deftags[:collections])
    expect(mytags[:image_unique_id]).to eq(deftags[:image_unique_id])
    expect(mytags[:coded_character_set]).to eq(deftags[:coded_character_set])
    expect(mytags[:modify_date]).to eq(deftags[:modify_date])

    expect(mytags).to be_valid
    expect(mytags.error_message).to be_empty
  end

  let(:mhash) { instance_double("MiniExiftool", class: MiniExiftool) }

  it 'saves exif tags when they initialized via exiftool hash (main items)' do
    hash = {
      'City' => %(Moscow),
      'CodedCharacterSet' => 'UTF8',
      'CollectionName' => 'Collection Name', 'CollectionURI' => 'www.site.com',
      'Copyright' => %(2014 \(c\) Andrey Bizyaev),
      'LocationShownCountryCode' => 'RU',
      'Country-PrimaryLocationName' => 'Russia',
      'CreateDate' => DateTime.new(2014, 8, 12, 21, 58, 55),
      'Artist' => 'Andrey Bizyaev; Matz',
      'DateTimeOriginal' => DateTime.new(2014, 01, 21, 11, 5, 5),
      'GPSPosition' => 'position',
      'GPSLatitude' => '55 36 31.49',
      'GPSLatitudeRef' => 'N',
      'GPSLongitude' => '37 43 28.27',
      'GPSLongitudeRef' => 'E',
      'GPSAltitude' => '170.0',
      'GPSAltitudeRef' => 'Above Sea Level',
      'ImageUniqueID' => '20140223-003748-0123',
      'Keywords' => %w(keyword1 keyword2),
      'Sub-location' => %(Pushkin street 1),
      'ModifyDate' => 'now',
      'Province-State' => 'State',
      'LocationShownWorldRegion' => %(Europe)
      }

    allow(mhash).to receive(:[]) { |t| hash[t] }
    allow(mhash).to receive(:is_a?).with(MiniExiftool).and_return(true)
    allow(mhash).to receive(:is_a?).with(Hash).and_return(false)
    allow(mhash).to receive(:is_a?).with(ExifTagger::TagCollection).and_return(false)

    mytags = described_class.new(mhash)

    expect(mytags[:city]).to include(%(Moscow))
    expect(mytags[:coded_character_set]).to include('UTF8')
    expect(mytags[:collections]).to eql(collection_name: 'Collection Name',
                                        collection_uri: 'www.site.com')
    expect(mytags[:copyright]).to include(%(2014 (c) Andrey Bizyaev))
    expect(mytags[:country_code]).to include('RU')
    expect(mytags[:country]).to include(%(Russia))
    expect(mytags[:create_date]).to eq(DateTime.new(2014, 8, 12, 21, 58, 55))
    expect(mytags[:creator]).to match_array(%w(Andrey\ Bizyaev Matz))
    expect(mytags[:date_time_original]).to eq(DateTime.new(2014, 01, 21, 11, 5, 5))
    expect(mytags[:gps_created]).to eql(gps_latitude: '55 36 31.49',
                                        gps_latitude_ref: 'N',
                                        gps_longitude: '37 43 28.27',
                                        gps_longitude_ref: 'E',
                                        gps_altitude: '170.0',
                                        gps_altitude_ref: 'Above Sea Level')
    expect(mytags[:image_unique_id]).to include('20140223-003748-0123')
    expect(mytags[:keywords]).to match_array(%w(keyword1 keyword2))
    expect(mytags[:location]).to include(%(Pushkin street 1))
    expect(mytags[:modify_date]).to include('now')
    expect(mytags[:state]).to include(%(State))
    expect(mytags[:world_region]).to include(%(Europe))

    expect(mytags).to be_valid
    expect(mytags.error_message).to be_empty
  end

  it 'saves exif tags when they initialized via exiftool hash (alt items)' do
    hash = {
      'LocationShownCity' => %(CityAlt),
      'CodedCharacterSet' => 'UTF8',
      'CollectionName' => 'Collection Name', 'CollectionURI' => 'www.site.com',
      'Rights' => %(2016 \(c\) Andrey Bizyaev),
      'LocationShownCountryCode' => 'RU',
      'LocationShownCountryName' => 'CountryAlt',
      'DigitalCreationDate' => '2005:05:05', 'DigitalCreationTime' => '05:05:05+05:00',
      'Creator' => ['CreatorAlt1', 'CreatorAlt2'],
      'DateCreated' => DateTime.new(2016, 01, 21, 11, 5, 5),
      'GPSPosition' => 'position',
      'GPSLatitude' => '55 36 31.49',
      'GPSLatitudeRef' => 'N',
      'GPSLongitude' => '37 43 28.27',
      'GPSLongitudeRef' => 'E',
      'GPSAltitude' => '170.0',
      'GPSAltitudeRef' => 'Above Sea Level',
      'ImageUniqueID' => '20140223-003748-0123',
      'Subject' => %w(subject1 subject2),
      'LocationShownSublocation' => %(Alt street 1),
      'ModifyDate' => 'now',
      'LocationShownProvinceState' => 'StateAlt',
      'LocationShownWorldRegion' => %(Europe)
      }

    allow(mhash).to receive(:[]) { |t| hash[t] }
    allow(mhash).to receive(:is_a?).with(MiniExiftool).and_return(true)
    allow(mhash).to receive(:is_a?).with(Hash).and_return(false)
    allow(mhash).to receive(:is_a?).with(ExifTagger::TagCollection).and_return(false)

    mytags = described_class.new(mhash)

    expect(mytags[:city]).to include(%(CityAlt))
    expect(mytags[:coded_character_set]).to include('UTF8')
    expect(mytags[:collections]).to eql(collection_name: 'Collection Name',
                                        collection_uri: 'www.site.com')
    expect(mytags[:copyright]).to include(%(2016 (c) Andrey Bizyaev))
    expect(mytags[:country_code]).to include('RU')
    expect(mytags[:country]).to include(%(CountryAlt))
    expect(mytags[:create_date]).to eq(DateTime.new(2005, 5, 5, 5, 5, 5, '+05:00'))
    expect(mytags[:creator]).to match_array(%w(CreatorAlt1 CreatorAlt2))
    expect(mytags[:date_time_original]).to eq(DateTime.new(2016, 01, 21, 11, 5, 5))
    expect(mytags[:gps_created]).to eql(gps_latitude: '55 36 31.49',
                                        gps_latitude_ref: 'N',
                                        gps_longitude: '37 43 28.27',
                                        gps_longitude_ref: 'E',
                                        gps_altitude: '170.0',
                                        gps_altitude_ref: 'Above Sea Level')
    expect(mytags[:image_unique_id]).to include('20140223-003748-0123')
    expect(mytags[:keywords]).to match_array(%w(subject1 subject2))
    expect(mytags[:location]).to include(%(Alt street 1))
    expect(mytags[:modify_date]).to include('now')
    expect(mytags[:state]).to include(%(StateAlt))
    expect(mytags[:world_region]).to include(%(Europe))

    expect(mytags).to be_valid
    expect(mytags.error_message).to be_empty
  end

  # TODO: test set individual tags via mini_exiftool hash

  # TODO: test previous via new mechanizm
  context 'when previous tag value (read by mini_exiftool) exists -' do
    mytags = described_class.new(
        creator: %w(Andrey\ Bizyaev Matz),
        copyright: %(2014 \(c\) Andrey Bizyaev),
        keywords: %w(keyword1 keyword2),
        world_region: %(Europe),
        country: %(Russia),
        country_code: 'RU',
        state: %(State),
        city: %(Moscow),
        location: %(Pushkin street 1),
        gps_created: { gps_latitude: '55 36 31.49',
                       gps_latitude_ref: 'N',
                       gps_longitude: '37 43 28.27',
                       gps_longitude_ref: 'E',
                       gps_altitude: '170.0',
                       gps_altitude_ref: 'Above Sea Level' },
        collections: { collection_name: 'Collection Name',
                       collection_uri: 'www.site.com' },
        image_unique_id: '20140223-003748-0123',
        coded_character_set: 'UTF8',
        modify_date: 'now')

    mytags.check_for_warnings(original_values: {'Copyright' => 'Original copyright',
                                  'State' => 'Old state'})
    it 'produce warnings' do
      expect(mytags).to be_with_warnings
      expect(mytags.warning_message).to include('Original copyright')
      expect(mytags.warning_message).to include('Old state')
    end
  end

  context 'when receives wrong tag values' do
    subject do
      described_class.new(
        world_region: %(Europe),
        country: %(Russia),
        state: %(State),
        city: %(Very_very_long_name_of_the_supur_puper_city),
        location: %(Location_too_long123123456789012345))
    end
    it { should_not be_valid }
    its(:error_message) { should include('Very_very_long_name_of_the_supur_puper_city') }
    its(:error_message) { should include('Location_too_long123123456789012345') }
  end
end

# DateTimeOriginal                : 2013-03-07 10:51:07
# CreateDate                      : 2013-03-07 10:51:07
# ModifyDate                      : 2013-03-20 23:17:06
# Creator                         : Andrey Bizyaev (photographer), Andrey Bizyaev (camera owner)
# Copyright                       : 2013 (c) Andrey Bizyaev. All Rights Reserved.
# Keywords                        : работа, корпоратив, 8 марта,
# LocationShownWorldRegion      : Europe
# Country                         : Russia
# LocationShownCountryCode        : RU
# State                           : Москва
# City                            : Москва
# Location                        : Вавилова 23
# GPSLatitude                     : 55 41 49.51000000 N
# GPSLatitudeRef                  : North
# GPSLongitude                    : 37 34 23.61000000 E
# GPSLongitudeRef                 : East
# GPSAltitude                     : 131 m Above Sea Level
# GPSAltitudeRef                  : Above Sea Level
# CollectionName                  : Сбербанк 8-марта, 111, 444, 4441
# CollectionURI                   : anblab.net/, www3, 222, 555, 5551
# ImageUniqueID                   : 20130308-SRLLL
# CodedCharacterSet               : UTF8
