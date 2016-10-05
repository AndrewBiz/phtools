#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/exif_tagger'

describe ExifTagger::TagWriter do
  let(:output) { double('output').as_null_object }
  let(:writer) do
    described_class.new(script_name: 'exif_tagger.txt',
                           memo: 'automatically generated',
                           output: output)
  end
  let(:mfile) { StringIO.new('script.txt', 'w+:utf-8') }

  before :each do
    allow(File).to receive(:open).and_return(mfile)
    allow(File).to receive(:close).and_return true
  end

  it 'informs it has started generated script' do
    expect(output).to receive(:puts).with("*** Preparing exiftool script 'exif_tagger.txt' ...")
    writer
  end

  it 'knows the exiftool command to be run' do
    expect(writer.command).to eql('exiftool -@ exif_tagger.txt')
  end

  it 'creates script file to be used by exiftool' do
    writer
    expect(mfile.string).to include('exiftool script')
    expect(mfile.string).to include('usage: exiftool -@')
    expect(mfile.string).to include('automatically generated')
  end

  it 'starts with counter (number of added files) == 0' do
    expect(writer.added_files_count).to eql 0
  end

  it 'adds instructions into script' do
    tags2write = ExifTagger::TagCollection.new(
      creator: %w(Andrey\ Bizyaev Matz),
      copyright: %{2014 (c) Andrey Bizyaev},
      keywords: %w(keyword1 keyword2),
      world_region: %(Europe),
      country: %(Russia),
      state: %(State),
      city: %(Moscow),
      location: %(Pushkin street 1),
      gps_created: {
        gps_latitude: '55 36 31.49',
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
    options2write = %w(-v0 -P -overwrite_original -ignoreMinorErrors)

    writer.add_to_script(filename: 'test.jpg',
                         tags: tags2write,
                         options: options2write)

    expect(mfile.string).to include('-MWG:Creator-=Andrey Bizyaev')
    expect(mfile.string).to include('-MWG:Creator+=Andrey Bizyaev')
    expect(mfile.string).to include('-MWG:Creator-=Matz')
    expect(mfile.string).to include('-MWG:Creator+=Matz')
    expect(mfile.string).to include('-MWG:Copyright=2014 (c) Andrey Bizyaev')
    expect(mfile.string).to include('-MWG:Keywords-=keyword1')
    expect(mfile.string).to include('-MWG:Keywords+=keyword1')
    expect(mfile.string).to include('-MWG:Keywords-=keyword2')
    expect(mfile.string).to include('-MWG:Keywords+=keyword2')
    expect(mfile.string).to include('-XMP-iptcExt:LocationShownWorldRegion=Europe')
    expect(mfile.string).to include('-MWG:Country=Russia')
    expect(mfile.string).to include('-MWG:State=State')
    expect(mfile.string).to include('-MWG:City=Moscow')
    expect(mfile.string).to include('-MWG:Location=Pushkin street 1')
    expect(mfile.string).to include('-GPSLatitude="55 36 31.49"')
    expect(mfile.string).to include('-GPSLatitudeRef=N')
    expect(mfile.string).to include('-GPSLongitude="37 43 28.27"')
    expect(mfile.string).to include('-GPSLongitudeRef=E')
    expect(mfile.string).to include('-GPSAltitude=170.0')
    expect(mfile.string).to include('-GPSAltitudeRef=Above Sea Level')
    expect(mfile.string).to include('-XMP-mwg-coll:Collections-={CollectionName=Collection Name, CollectionURI=www.site.com}')
    expect(mfile.string).to include('-XMP-mwg-coll:Collections+={CollectionName=Collection Name, CollectionURI=www.site.com}')
    expect(mfile.string).to include('-ImageUniqueID=20140223-003748-0123')
    expect(mfile.string).to include('-IPTC:CodedCharacterSet=UTF8')
    expect(mfile.string).to include('-EXIF:ModifyDate=now')
    expect(mfile.string).to include('test.jpg')
    expect(mfile.string).to include('-v0')
    expect(mfile.string).to include('-P')
    expect(mfile.string).to include('-overwrite_original')
    expect(mfile.string).to include('-overwrite_original')
    expect(mfile.string).to include('-execute')
  end

  it 'increments counter after :add_to_script' do
    tags2write = ExifTagger::TagCollection.new(
      creator: %w(Andrey),
      copyright: %(Andrey Bizyaev),
      modify_date: 'now')

    writer.add_to_script(filename: 'test.jpg', tags: tags2write)
    expect(writer.added_files_count).to eql 1
    expect(mfile.string).to include('# **(1)**')
    writer.add_to_script(filename: 'test.jpg', tags: tags2write)
    expect(writer.added_files_count).to eql 2
    writer.add_to_script(filename: 'test.jpg', tags: tags2write)
    writer.add_to_script(filename: 'test.jpg', tags: tags2write)
    writer.add_to_script(filename: 'test.jpg', tags: tags2write)
    expect(writer.added_files_count).to eql 5
    expect(mfile.string).to include('# **(2)**')
    expect(mfile.string).to include('# **(3)**')
    expect(mfile.string).to include('# **(4)**')
    expect(mfile.string).to include('# **(5)**')
  end

  it 'informs when finished the script preparation' do
    tags2write = ExifTagger::TagCollection.new(
      creator: %w(Andrey),
      copyright: %(Andrey Bizyaev),
      modify_date: 'now')

    allow(writer).to receive(:system) { true }
    expect(output).to receive(:puts).with("*** Finished preparation of the script 'exif_tagger.txt'")
    writer.add_to_script(filename: 'foto1.jpg', tags: tags2write)
    writer.close_script
  end

  it 'runs the exiftool script' do
    tags2write = ExifTagger::TagCollection.new(
      creator: %w(Andrey),
      copyright: %(Andrey Bizyaev),
      modify_date: 'now')

    expect(output).to receive(:puts).with("*** Preparing exiftool script 'exif_tagger.txt' ...")
    allow(writer).to receive(:system) { true }
    writer.add_to_script(filename: 'foto2.jpg', tags: tags2write)

    expect(output).to receive(:puts).with("*** Finished preparation of the script 'exif_tagger.txt'")
    expect(output).to receive(:puts).with('*** Running exiftool -@ exif_tagger.txt ...')
    expect(output).to receive(:puts).with('*** Finished exiftool -@ exif_tagger.txt')
    expect(writer.added_files_count).to eql 1
    expect(writer).to receive(:system).once
    writer.run!
  end

  it 'does not run the exiftool script if no files were added' do
    expect(output).to receive(:puts).with("*** Preparing exiftool script 'exif_tagger.txt' ...")
    allow(writer).to receive(:system) { true }
    expect(writer.added_files_count).to eql 0
    expect(writer).not_to receive(:system)
    expect(output).to receive(:puts).with("*** Finished preparation of the script 'exif_tagger.txt'")
    expect(output).not_to receive(:puts).with('*** Running exiftool -@ exif_tagger.txt ...')
    expect(output).not_to receive(:puts).with('*** Finished exiftool -@ exif_tagger.txt')
    expect(output).to receive(:puts).with('*** Nothing to update, skip running exiftool -@ exif_tagger.txt ...')
    writer.run!
  end
end
