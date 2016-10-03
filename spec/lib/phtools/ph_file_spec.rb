#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'phtools/ph_file'

RSpec.describe PhTools::PhFile, 'constants' do
  it 'includes NICKNAME_MIN_SIZE == 3' do
    expect(PhTools::PhFile::NICKNAME_MIN_SIZE).to eq 3
  end

  it 'includes NICKNAME_MAX_SIZE == 6' do
    expect(PhTools::PhFile::NICKNAME_MAX_SIZE).to eq 6
  end

  it 'includes NICKNAME_SIZE within the range of MIN-MAX' do
    expect(PhTools::PhFile::NICKNAME_SIZE).to be <= PhTools::PhFile::NICKNAME_MAX_SIZE
    expect(PhTools::PhFile::NICKNAME_SIZE).to be >= PhTools::PhFile::NICKNAME_MIN_SIZE
  end
end

RSpec.describe PhTools::PhFile do
  context "when it is created" do
    it 'stores filename with dirname .' do
      fn = described_class.new('file.ext')
      expect(fn.filename).to eq('./file.ext')
    end

    it 'stores filename with dirname aaa/bbb' do
      fn = described_class.new('aaa/bbb/file.ext')
      expect(fn.filename).to eq('aaa/bbb/file.ext')
    end

    it 'prints object as filename' do
      fn = described_class.new('file.ext')
      expect(fn.to_s).to eq('./file.ext')
    end

    it 'stores file dir name' do
      fn = described_class.new('./aaa/bbb/file.ext')
      expect(fn.dirname).to eq('./aaa/bbb')
    end

    it 'stores file base name' do
      fn = described_class.new('./aaa/bbb/file.ext')
      expect(fn.basename).to eq('file')
    end

    it 'stores file extention name' do
      fn = described_class.new('./aaa/bbb/file.ext')
      expect(fn.extname).to eq('.ext')
    end

    it 'stores file type' do
      fn = described_class.new('./aaa/bbb/file.EXT')
      expect(fn.type).to eq('ext')
    end

    it 'stores empty file type for file without extention' do
      fn = described_class.new('./aaa/bbb/file')
      expect(fn.type).to eq('')
    end

    it 'is comparable to other objects via filename' do
      fn1 = described_class.new('file1.ext')
      fn2 = described_class.new('file2.ext')
      fn3 = described_class.new('file1.ext')

      expect(fn1).not_to eq(fn2)
      expect(fn1).to eq(fn3)
    end
  end

  describe 'helps to check the type of' do
    example 'file.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj).to be_image
      expect(obj).to be_image_normal
      expect(obj).not_to be_image_raw
      expect(obj).not_to be_video
      expect(obj).not_to be_audio
    end

    example 'file.arw' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj).to be_image
      expect(obj).not_to be_image_normal
      expect(obj).to be_image_raw
      expect(obj).not_to be_video
      expect(obj).not_to be_audio
    end

    example 'file.mov' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj).not_to be_image
      expect(obj).not_to be_image_normal
      expect(obj).not_to be_image_raw
      expect(obj).to be_video
      expect(obj).not_to be_audio
    end

    example 'file.wav' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj).not_to be_image
      expect(obj).not_to be_image_normal
      expect(obj).not_to be_image_raw
      expect(obj).not_to be_video
      expect(obj).to be_audio
    end
  end

  context 'when validate the author NICKNAME' do
    it "reports wrong size for 'A'" do |this_example|
      ok, message = described_class.validate_author(get_argument(this_example.metadata[:description]))
      expect(ok).to be false
      expect(message).to include('wrong author size')
    end

    it "reports wrong size for 'ANNB'" do |this_example|
      ok, message = described_class.validate_author(get_argument(this_example.metadata[:description]))
      expect(ok).to be false
      expect(message).to include('wrong author size')
    end

    it "and keeps silince for 'ANB'" do |this_example|
      ok, message = described_class.validate_author(get_argument(this_example.metadata[:description]))
      expect(ok).to be true
      expect(message).to be_empty
    end

    it "and reports wrong SPACE char for 'A N'" do |this_example|
      ok, message = described_class.validate_author(get_argument(this_example.metadata[:description]))
      expect(ok).to be false
      expect(message).to include('should not contain spaces')
    end

    it "and reports wrong '_' char for 'A_B'" do |this_example|
      ok, message = described_class.validate_author(get_argument(this_example.metadata[:description]))
      expect(ok).to be false
      expect(message).to include('_')
    end

    it "and reports wrong '-' char for 'A-B'" do |this_example|
      ok, message = described_class.validate_author(get_argument(this_example.metadata[:description]))
      expect(ok).to be false
      expect(message).to include('-')
    end

    it "and reports wrong DIGIT char for 'A5B'" do |this_example|
      ok, message = described_class.validate_author(get_argument(this_example.metadata[:description]))
      expect(ok).to be false
      expect(message).to include('should not contain digits')
    end

    it "and reports wrong non-ASCII char for 'АБВ'" do |this_example|
      ok, message = described_class.validate_author(get_argument(this_example.metadata[:description]))
      expect(ok).to be false
      expect(message).to include('should contain only ASCII')
    end
  end

  describe 'parses the basename of' do
    example '20011231-112233_ANB[20010101-ABCDEF]{flags}cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '20011231-112233_ANB[20010101-ABCDEF]{flags}'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '112233'
      expect(obj.basename_part[:author]).to eq 'ANB'
      expect(obj.basename_part[:id]).to eq '20010101-ABCDEF'
      expect(obj.basename_part[:flags]).to eq 'flags'
    end

    example '20011231-112233_ANB[20010101-ABCDEF]cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '20011231-112233_ANB[20010101-ABCDEF]'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '112233'
      expect(obj.basename_part[:author]).to eq 'ANB'
      expect(obj.basename_part[:id]).to eq '20010101-ABCDEF'
      expect(obj.basename_part[:flags]).to eq ''
    end

    example '20011231-112233_ANB_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '20011231-112233_ANB_'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '112233'
      expect(obj.basename_part[:author]).to eq 'ANB'
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    describe '(STANDARD template)' do
      example '20011231-112233_ANB cleanname.jpg' do |this_example|
        obj = described_class.new(this_example.metadata[:description])
        expect(obj.basename_part[:prefix]).to eq '20011231-112233_ANB '
        expect(obj.basename_part[:clean]).to eq 'cleanname'
        expect(obj.basename_part[:date]).to eq '20011231'
        expect(obj.basename_part[:time]).to eq '112233'
        expect(obj.basename_part[:author]).to eq 'ANB'
        expect(obj.basename_part[:id]).to eq ''
        expect(obj.basename_part[:flags]).to eq ''
      end

      example '20011231-112233_ANDREW cleanname.jpg' do |this_example|
        obj = described_class.new(this_example.metadata[:description])
        expect(obj.basename_part[:prefix]).to eq '20011231-112233_ANDREW '
        expect(obj.basename_part[:clean]).to eq 'cleanname'
        expect(obj.basename_part[:date]).to eq '20011231'
        expect(obj.basename_part[:time]).to eq '112233'
        expect(obj.basename_part[:author]).to eq 'ANDREW'
        expect(obj.basename_part[:id]).to eq ''
        expect(obj.basename_part[:flags]).to eq ''
      end
    end

    example '20011231-1122_ANB_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '20011231-1122_ANB_'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '1122'
      expect(obj.basename_part[:author]).to eq 'ANB'
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    example '20011231-1122-ANB_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '20011231-1122-ANB_'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '1122'
      expect(obj.basename_part[:author]).to eq 'ANB'
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    example '20011231-1122_ANB cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '20011231-1122_ANB '
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '1122'
      expect(obj.basename_part[:author]).to eq 'ANB'
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    example '20011231-1122_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '20011231-1122_'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '1122'
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    example '20011231-1122 cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '20011231-1122 '
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '1122'
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    example '20011231_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '20011231_'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    example '20011231 cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '20011231 '
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    example '20011231-cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '20011231-'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    example '2001_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '2001_'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '2001'
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    example '2001-cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '2001-'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '2001'
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    example '2001 cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq '2001 '
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '2001'
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    example 'cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_part[:prefix]).to eq ''
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq ''
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end
  end

  describe 'reveals date_time from the filename of' do
    example '20011231-112233_ANB cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.date_time).to eq DateTime.strptime('2001-12-31T11:22:33+00:00')
      expect(obj.date_time_ok?).to be true
    end

    example '20011231-112269_ANB cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.date_time_ok?).to be false
    end

    example '20011231-1122_ANB cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.date_time).to eq DateTime.strptime('2001-12-31T11:22:00+00:00')
      expect(obj.date_time_ok?).to be true
    end

    example '20011231_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.date_time).to eq DateTime.strptime('2001-12-31T00:00:00+00:00')
      expect(obj.date_time_ok?).to be true
    end

    example '2001_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.date_time).to eq DateTime.strptime('2001-01-01T00:00:00+00:00')
      expect(obj.date_time_ok?).to be true
    end
  end

  describe 'checks if the name complies with PHTOOLS standard for' do
    example '20011231-112233_ANB[20010101-ABCDEF]{flags}cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_is_standard?).to be false
    end

    example '20011231-112233_ANB[20010101-ABCDEF]cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_is_standard?).to be false
    end

    example '20011231-112233_ANB_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_is_standard?).to be false
    end

    example '20011231-112233_ANB-cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_is_standard?).to be false
    end

    example '20011231-112233_ANB_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_is_standard?).to be false
    end

    # STANDARD name!
    example '20011231-112233_ANB cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_is_standard?).to be true
    end

    example '20011231-1122_ANB cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_is_standard?).to be false
    end

    example '20011231-1122_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_is_standard?).to be false
    end

    example '20011231_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_is_standard?).to be false
    end

    example '2001_cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_is_standard?).to be false
    end

    # author should be upcased
    example '20011231-112233_anb cleanname.jpg' do |this_example|
      obj = described_class.new(this_example.metadata[:description])
      expect(obj.basename_is_standard?).to be false
    end
  end

  describe 'generates standard file name' do
    context 'without changes of the inner state' do
      specify 'when I set only date_time and author' do
        obj = described_class.new('cleanname.jpg')
        expect(obj.standardize(date_time: DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S'),
                               author: 'anb')).to eq './20131130-183657_ANB cleanname.jpg'
        expect(obj.basename).to eq 'cleanname'
        expect(obj.basename_clean).to eq 'cleanname'
        expect(obj.dirname).to eq '.'
        expect(obj.extname).to eq '.jpg'
        expect(obj.author).to be_empty
        expect(obj.date_time).to eq DateTime.new(0)
        expect(obj.basename_is_standard?).to be false
      end

      specify 'when I change all parts of the filename' do
        obj = described_class.new('cleanname.jpg')
        expect(obj.standardize(basename_clean: 'clean_name',
                               extname: '.jpeg',
                               dirname: 'changed/dir',
                               date_time: DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S'),
                               author: 'anb')).to eq 'changed/dir/20131130-183657_ANB clean_name.jpeg'
        expect(obj.basename).to eq 'cleanname'
        expect(obj.basename_clean).to eq 'cleanname'
        expect(obj.dirname).to eq '.'
        expect(obj.extname).to eq '.jpg'
        expect(obj.author).to be_empty
        expect(obj.date_time).to eq DateTime.new(0)
        expect(obj.basename_is_standard?).to be false
      end
    end

    context 'with change of the inner state' do
      specify 'when I set only date_time and author' do
        obj = described_class.new('cleanname.jpg')
        expect(obj.standardize!(date_time: DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S'),
                                author: 'anb')).to eq './20131130-183657_ANB cleanname.jpg'
        expect(obj.filename).to eq './20131130-183657_ANB cleanname.jpg'
        expect(obj.basename).to eq '20131130-183657_ANB cleanname'
        expect(obj.basename_clean).to eq 'cleanname'
        expect(obj.dirname).to eq '.'
        expect(obj.extname).to eq '.jpg'
        expect(obj.author).to eq 'ANB'
        expect(obj.date_time).to eq DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S')
        expect(obj.basename_is_standard?).to be true
      end

      specify 'when I change all parts of the filename' do
        obj = described_class.new('cleanname.jpg')
        expect(obj.standardize!(basename_clean: 'clean_name',
                                extname: '.jpeg',
                                dirname: 'changed/dir',
                                date_time: DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S'),
                                author: 'anb')).to eq 'changed/dir/20131130-183657_ANB clean_name.jpeg'
        expect(obj.filename).to eq 'changed/dir/20131130-183657_ANB clean_name.jpeg'
        expect(obj.basename).to eq '20131130-183657_ANB clean_name'
        expect(obj.basename_clean).to eq 'clean_name'
        expect(obj.dirname).to eq 'changed/dir'
        expect(obj.extname).to eq '.jpeg'
        expect(obj.author).to eq 'ANB'
        expect(obj.date_time).to eq DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S')
        expect(obj.basename_is_standard?).to be true
      end
    end
  end

  describe 'generates clean file name' do
    context 'without changes of the inner state' do
      specify "when I just clean the name for '20131130-183657_ANB cleanname.jpg'" do |this_example|
        obj = described_class.new(get_argument(this_example.metadata[:description]))
        expect(obj.cleanse).to eq './cleanname.jpg'
        expect(obj.basename).to eq '20131130-183657_ANB cleanname'
        expect(obj.basename_clean).to eq 'cleanname'
        expect(obj.dirname).to eq '.'
        expect(obj.extname).to eq '.jpg'
        expect(obj.author).to eq 'ANB'
        expect(obj.date_time).to eq DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S')
        expect(obj.basename_is_standard?).to be true
      end

      specify "when I change all parts of the '20131130-183657_ANB cleanname.jpg'" do |this_example|
        obj = described_class.new(get_argument(this_example.metadata[:description]))
        expect(obj.cleanse(dirname: 'new/dir',
                           basename_clean: 'clean_name',
                           extname: '.jpeg')).to eq 'new/dir/clean_name.jpeg'
        expect(obj.basename).to eq '20131130-183657_ANB cleanname'
        expect(obj.basename_clean).to eq 'cleanname'
        expect(obj.dirname).to eq '.'
        expect(obj.extname).to eq '.jpg'
        expect(obj.author).to eq 'ANB'
        expect(obj.date_time).to eq DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S')
        expect(obj.basename_is_standard?).to be true
      end
    end

    context 'with changes of the inner state' do
      specify "when I just clean the name for '20131130-183657_ANB cleanname.jpg'" do |this_example|
        obj = described_class.new(get_argument(this_example.metadata[:description]))
        expect(obj.cleanse!).to eq './cleanname.jpg'
        expect(obj.basename).to eq 'cleanname'
        expect(obj.basename_clean).to eq 'cleanname'
        expect(obj.dirname).to eq '.'
        expect(obj.extname).to eq '.jpg'
        expect(obj.author).to be_empty
        expect(obj.date_time).to eq DateTime.new(0)
        expect(obj.basename_is_standard?).to be false
      end

      it "when I change all parts of the '20131130-183657_ANB cleanname.jpg'" do |this_example|
        obj = described_class.new(get_argument(this_example.metadata[:description]))
        expect(obj.cleanse!(dirname: 'new/dir',
                            basename_clean: 'clean_name',
                            extname: '.jpeg')).to eq 'new/dir/clean_name.jpeg'
        expect(obj.basename).to eq 'clean_name'
        expect(obj.basename_clean).to eq 'clean_name'
        expect(obj.dirname).to eq 'new/dir'
        expect(obj.extname).to eq '.jpeg'
        expect(obj.author).to be_empty
        expect(obj.date_time).to eq DateTime.new(0)
        expect(obj.basename_is_standard?).to be false
      end
    end
  end

  describe 'changes dirname' do
    specify "when I set new dirname for '20131130-183657_ANB cleanname.jpg'" do |this_example|
      obj = described_class.new(get_argument(this_example.metadata[:description]))
      expect(obj.basename).to eq '20131130-183657_ANB cleanname'
      expect(obj.basename_clean).to eq 'cleanname'
      expect(obj.dirname).to eq '.'
      expect(obj.extname).to eq '.jpg'
      expect(obj.author).to eq 'ANB'
      expect(obj.date_time).to eq DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S')
      expect(obj.basename_is_standard?).to be true

      obj.dirname = 'new/dir/name'
      expect(obj.filename).to eq 'new/dir/name/20131130-183657_ANB cleanname.jpg'
      expect(obj.basename).to eq '20131130-183657_ANB cleanname'
      expect(obj.basename_clean).to eq 'cleanname'
      expect(obj.dirname).to eq 'new/dir/name'
      expect(obj.extname).to eq '.jpg'
      expect(obj.author).to eq 'ANB'
      expect(obj.date_time).to eq DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S')
      expect(obj.basename_is_standard?).to be true
    end
  end
end
