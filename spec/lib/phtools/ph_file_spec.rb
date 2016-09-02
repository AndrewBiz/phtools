#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'spec_helper'
require 'ph_file'

describe FTools::FTFile, 'constants' do
  it 'include NICKNAME_MIN_SIZE == 3' do
    expect(FTools::FTFile::NICKNAME_MIN_SIZE).to eq 3
  end

  it 'include NICKNAME_MAX_SIZE == 6' do
    expect(FTools::FTFile::NICKNAME_MAX_SIZE).to eq 6
  end

  it 'include NICKNAME_SIZE within the range of MIN-MAX' do
    expect(FTools::FTFile::NICKNAME_SIZE).to be <=
      FTools::FTFile::NICKNAME_MAX_SIZE
    expect(FTools::FTFile::NICKNAME_SIZE).to be >=
      FTools::FTFile::NICKNAME_MIN_SIZE
  end
end

describe FTools::FTFile do
  it 'stores filename with dirname .' do
    fn = FTools::FTFile.new('file.ext')
    expect(fn.filename).to eq('./file.ext')
  end

  it 'stores filename with dirname aaa/bbb' do
    fn = FTools::FTFile.new('aaa/bbb/file.ext')
    expect(fn.filename).to eq('aaa/bbb/file.ext')
  end

  it 'prints object as filename' do
    fn = FTools::FTFile.new('file.ext')
    expect(fn.to_s).to eq('./file.ext')
  end

  it 'stores file dir name' do
    fn = FTools::FTFile.new('./aaa/bbb/file.ext')
    expect(fn.dirname).to eq('./aaa/bbb')
  end

  it 'stores file base name' do
    fn = FTools::FTFile.new('./aaa/bbb/file.ext')
    expect(fn.basename).to eq('file')
  end

  it 'stores file extention name' do
    fn = FTools::FTFile.new('./aaa/bbb/file.ext')
    expect(fn.extname).to eq('.ext')
  end

  it 'is comparable to other FT objects via filename' do
    fn1 = FTools::FTFile.new('file1.ext')
    fn2 = FTools::FTFile.new('file2.ext')
    fn3 = FTools::FTFile.new('file1.ext')

    expect(fn1).not_to eq(fn2)
    expect(fn1).to eq(fn3)
  end

  describe 'validates the author NICKNAME' do
    an1 = 'A'
    it "and reports wrong size for '#{an1}'" do
      ok, message = FTools::FTFile.validate_author(an1)
      expect(ok).to be false
      expect(message).to include('wrong author size')
    end
    an2 = 'ANNB'
    it "and reports wrong size for '#{an2}'" do
      ok, message = FTools::FTFile.validate_author(an2)
      expect(ok).to be false
      expect(message).to include('wrong author size')
    end
    an3 = 'ANB'
    it "and keeps silince for '#{an3}'" do
      ok, message = FTools::FTFile.validate_author(an3)
      expect(ok).to be true
      expect(message).to be_empty
    end
    an4 = 'A N'
    it "and reports wrong SPACE char for '#{an4}'" do
      ok, message = FTools::FTFile.validate_author(an4)
      expect(ok).to be false
      expect(message).to include('should not contain spaces')
    end
    an5 = 'A_B'
    it "and reports wrong '_' char for '#{an5}'" do
      ok, message = FTools::FTFile.validate_author(an5)
      expect(ok).to be false
      expect(message).to include('_')
    end
    an6 = 'A-B'
    it "and reports wrong '-' char for '#{an6}'" do
      ok, message = FTools::FTFile.validate_author(an6)
      expect(ok).to be false
      expect(message).to include('-')
    end
    an7 = 'A5B'
    it "and reports wrong DIGIT char for '#{an7}'" do
      ok, message = FTools::FTFile.validate_author(an7)
      expect(ok).to be false
      expect(message).to include('should not contain digits')
    end
    an8 = 'AБB'
    it "and reports wrong non-ASCII char for '#{an8}'" do
      ok, message = FTools::FTFile.validate_author(an8)
      expect(ok).to be false
      expect(message).to include('should contain only ASCII')
    end
  end

  describe 'parses the basename of' do

    fn1 = '20011231-112233_ANB[20010101-ABCDEF]{flags}cleanname.jpg'
    it fn1 do
      obj = FTools::FTFile.new(fn1)
      expect(obj.basename_part[:prefix]).to eq \
        '20011231-112233_ANB[20010101-ABCDEF]{flags}'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '112233'
      expect(obj.basename_part[:author]).to eq 'ANB'
      expect(obj.basename_part[:id]).to eq '20010101-ABCDEF'
      expect(obj.basename_part[:flags]).to eq 'flags'
    end

    fn2 = '20011231-112233_ANB[20010101-ABCDEF]cleanname.jpg'
    it fn2 do
      obj = FTools::FTFile.new(fn2)
      expect(obj.basename_part[:prefix]).to eq \
        '20011231-112233_ANB[20010101-ABCDEF]'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '112233'
      expect(obj.basename_part[:author]).to eq 'ANB'
      expect(obj.basename_part[:id]).to eq '20010101-ABCDEF'
      expect(obj.basename_part[:flags]).to eq ''
    end

    fn3 = '20011231-112233_ANB_cleanname.jpg'
    it fn3 do
      obj = FTools::FTFile.new(fn3)
      expect(obj.basename_part[:prefix]).to eq \
      '20011231-112233_ANB_'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '112233'
      expect(obj.basename_part[:author]).to eq 'ANB'
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    describe '(STANDARD template)' do
      fn4 = '20011231-112233_ANB cleanname.jpg'
      it fn4 do
        obj = FTools::FTFile.new(fn4)
        expect(obj.basename_part[:prefix]).to eq \
        '20011231-112233_ANB '
        expect(obj.basename_part[:clean]).to eq 'cleanname'
        expect(obj.basename_part[:date]).to eq '20011231'
        expect(obj.basename_part[:time]).to eq '112233'
        expect(obj.basename_part[:author]).to eq 'ANB'
        expect(obj.basename_part[:id]).to eq ''
        expect(obj.basename_part[:flags]).to eq ''
      end
      fn5 = '20011231-112233_ANDREW cleanname.jpg'
      it fn5 do
        obj = FTools::FTFile.new(fn5)
        expect(obj.basename_part[:prefix]).to eq \
        '20011231-112233_ANDREW '
        expect(obj.basename_part[:clean]).to eq 'cleanname'
        expect(obj.basename_part[:date]).to eq '20011231'
        expect(obj.basename_part[:time]).to eq '112233'
        expect(obj.basename_part[:author]).to eq 'ANDREW'
        expect(obj.basename_part[:id]).to eq ''
        expect(obj.basename_part[:flags]).to eq ''
      end
    end

    fn7 = '20011231-1122_ANB_cleanname.jpg'
    it fn7 do
      obj = FTools::FTFile.new(fn7)
      expect(obj.basename_part[:prefix]).to eq \
      '20011231-1122_ANB_'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '1122'
      expect(obj.basename_part[:author]).to eq 'ANB'
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end
    fn8 = '20011231-1122-ANB_cleanname.jpg'
    it fn8 do
      obj = FTools::FTFile.new(fn8)
      expect(obj.basename_part[:prefix]).to eq \
      '20011231-1122-ANB_'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '1122'
      expect(obj.basename_part[:author]).to eq 'ANB'
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end
    fn9 = '20011231-1122_ANB cleanname.jpg'
    it fn9 do
      obj = FTools::FTFile.new(fn9)
      expect(obj.basename_part[:prefix]).to eq \
      '20011231-1122_ANB '
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '1122'
      expect(obj.basename_part[:author]).to eq 'ANB'
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    fn10 = '20011231-1122_cleanname.jpg'
    it fn10 do
      obj = FTools::FTFile.new(fn10)
      expect(obj.basename_part[:prefix]).to eq \
      '20011231-1122_'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '1122'
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end
    fn11 = '20011231-1122 cleanname.jpg'
    it fn11 do
      obj = FTools::FTFile.new(fn11)
      expect(obj.basename_part[:prefix]).to eq \
      '20011231-1122 '
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq '1122'
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    fn12 = '20011231_cleanname.jpg'
    it fn12 do
      obj = FTools::FTFile.new(fn12)
      expect(obj.basename_part[:prefix]).to eq \
      '20011231_'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end
    fn13 = '20011231 cleanname.jpg'
    it fn13 do
      obj = FTools::FTFile.new(fn13)
      expect(obj.basename_part[:prefix]).to eq \
      '20011231 '
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end
    fn14 = '20011231-cleanname.jpg'
    it fn14 do
      obj = FTools::FTFile.new(fn14)
      expect(obj.basename_part[:prefix]).to eq \
      '20011231-'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '20011231'
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    fn15 = '2001_cleanname.jpg'
    it fn15 do
      obj = FTools::FTFile.new(fn15)
      expect(obj.basename_part[:prefix]).to eq '2001_'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '2001'
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end
    fn16 = '2001-cleanname.jpg'
    it fn16 do
      obj = FTools::FTFile.new(fn16)
      expect(obj.basename_part[:prefix]).to eq '2001-'
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '2001'
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end
    fn17 = '2001 cleanname.jpg'
    it fn17 do
      obj = FTools::FTFile.new(fn17)
      expect(obj.basename_part[:prefix]).to eq '2001 '
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq '2001'
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end

    fn99 = 'cleanname.jpg'
    it fn99 do
      obj = FTools::FTFile.new(fn99)
      expect(obj.basename_part[:prefix]).to eq ''
      expect(obj.basename_part[:clean]).to eq 'cleanname'
      expect(obj.basename_part[:date]).to eq ''
      expect(obj.basename_part[:time]).to eq ''
      expect(obj.basename_part[:author]).to eq ''
      expect(obj.basename_part[:id]).to eq ''
      expect(obj.basename_part[:flags]).to eq ''
    end
  end

  describe 'reveals date_time from the filename' do
    fndt1 = '20011231-112233_ANB cleanname.jpg'
    it fndt1 do
      obj = FTools::FTFile.new(fndt1)
      expect(obj.date_time).to eq \
        DateTime.strptime('2001-12-31T11:22:33+00:00')
      expect(obj.date_time_ok?).to be true
    end
    fndt2 = '20011231-112269_ANB cleanname.jpg'
    it fndt2 do
      obj = FTools::FTFile.new(fndt2)
      expect(obj.date_time_ok?).to be false
    end
    fndt3 = '20011231-1122_ANB cleanname.jpg'
    it fndt3 do
      obj = FTools::FTFile.new(fndt3)
      expect(obj.date_time).to eq \
        DateTime.strptime('2001-12-31T11:22:00+00:00')
      expect(obj.date_time_ok?).to be true
    end
    fndt4 = '20011231_cleanname.jpg'
    it fndt4 do
      obj = FTools::FTFile.new(fndt4)
      expect(obj.date_time).to eq \
        DateTime.strptime('2001-12-31T00:00:00+00:00')
      expect(obj.date_time_ok?).to be true
    end
    fndt5 = '2001_cleanname.jpg'
    it fndt5 do
      obj = FTools::FTFile.new(fndt5)
      expect(obj.date_time).to eq \
        DateTime.strptime('2001-01-01T00:00:00+00:00')
      expect(obj.date_time_ok?).to be true
    end
  end

  describe 'checks if the name complies with FT standard for' do
    fts1 = '20011231-112233_ANB[20010101-ABCDEF]{flags}cleanname.jpg'
    it fts1 do
      obj = FTools::FTFile.new(fts1)
      expect(obj.basename_is_standard?).to be false
    end
    fts2 = '20011231-112233_ANB[20010101-ABCDEF]cleanname.jpg'
    it fts2 do
      obj = FTools::FTFile.new(fts2)
      expect(obj.basename_is_standard?).to be false
    end
    fts3 = '20011231-112233_ANB_cleanname.jpg'
    it fts3 do
      obj = FTools::FTFile.new(fts3)
      expect(obj.basename_is_standard?).to be false
    end
    fts4 = '20011231-112233_ANB-cleanname.jpg'
    it fts4 do
      obj = FTools::FTFile.new(fts4)
      expect(obj.basename_is_standard?).to be false
    end
    fts5 = '20011232-112233_ANB cleanname.jpg'
    it fts5 do
      obj = FTools::FTFile.new(fts5)
      expect(obj.basename_is_standard?).to be false
    end
    # STANDARD name!
    fts6 = '20011231-112233_ANB cleanname.jpg'
    it fts6 do
      obj = FTools::FTFile.new(fts6)
      expect(obj.basename_is_standard?).to be true
    end
    fts7 = '20011231-1122_ANB cleanname.jpg'
    it fts7 do
      obj = FTools::FTFile.new(fts7)
      expect(obj.basename_is_standard?).to be false
    end
    fts8 = '20011231-1122_cleanname.jpg'
    it fts8 do
      obj = FTools::FTFile.new(fts8)
      expect(obj.basename_is_standard?).to be false
    end
    fts9 = '20011231_cleanname.jpg'
    it fts9 do
      obj = FTools::FTFile.new(fts9)
      expect(obj.basename_is_standard?).to be false
    end
    fts10 = '2001_cleanname.jpg'
    it fts10 do
      obj = FTools::FTFile.new(fts10)
      expect(obj.basename_is_standard?).to be false
    end
    # author shpuld be upcased
    fts11 = '20011231-112233_anb cleanname.jpg'
    it fts11 do
      obj = FTools::FTFile.new(fts11)
      expect(obj.basename_is_standard?).to be false
    end
  end

  describe 'generates standard file name' do
    describe 'without changes of the inner state' do
      it 'when I set only date_time and author' do
        obj = FTools::FTFile.new('cleanname.jpg')
        expect(obj.standardize(date_time: DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S'),
                               author: 'anb'))
          .to eq './20131130-183657_ANB cleanname.jpg'
        expect(obj.basename).to eq 'cleanname'
        expect(obj.basename_clean).to eq 'cleanname'
        expect(obj.dirname).to eq '.'
        expect(obj.extname).to eq '.jpg'
        expect(obj.author).to be_empty
        expect(obj.date_time).to eq DateTime.new(0)
        expect(obj.basename_is_standard?).to be false
      end
      it 'when I change all parts of the filename' do
        obj = FTools::FTFile.new('cleanname.jpg')
        expect(obj.standardize(basename_clean: 'clean_name',
                               extname: '.jpeg',
                               dirname: 'changed/dir',
                               date_time: DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S'),
                               author: 'anb'))
          .to eq 'changed/dir/20131130-183657_ANB clean_name.jpeg'
        expect(obj.basename).to eq 'cleanname'
        expect(obj.basename_clean).to eq 'cleanname'
        expect(obj.dirname).to eq '.'
        expect(obj.extname).to eq '.jpg'
        expect(obj.author).to be_empty
        expect(obj.date_time).to eq DateTime.new(0)
        expect(obj.basename_is_standard?).to be false
      end
    end
    describe 'and updates inner state' do
      it 'when I set only date_time and author' do
        obj = FTools::FTFile.new('cleanname.jpg')
        expect(obj.standardize!(date_time: DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S'),
                               author: 'anb'))
          .to eq './20131130-183657_ANB cleanname.jpg'
        expect(obj.filename).to eq './20131130-183657_ANB cleanname.jpg'
        expect(obj.basename).to eq '20131130-183657_ANB cleanname'
        expect(obj.basename_clean).to eq 'cleanname'
        expect(obj.dirname).to eq '.'
        expect(obj.extname).to eq '.jpg'
        expect(obj.author).to eq 'ANB'
        expect(obj.date_time).to eq DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S')
        expect(obj.basename_is_standard?).to be true
      end
      it 'when I change all parts of the filename' do
        obj = FTools::FTFile.new('cleanname.jpg')
        expect(obj.standardize!(basename_clean: 'clean_name',
                                extname: '.jpeg',
                                dirname: 'changed/dir',
                                date_time: DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S'),
                                author: 'anb'))
          .to eq 'changed/dir/20131130-183657_ANB clean_name.jpeg'
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
    describe 'without changes of the inner state' do
      fcl01 = '20131130-183657_ANB cleanname.jpg'
      it "when I just clean the name for #{fcl01}" do
        obj = FTools::FTFile.new(fcl01)
        expect(obj.cleanse).to eq './cleanname.jpg'
        expect(obj.basename).to eq '20131130-183657_ANB cleanname'
        expect(obj.basename_clean).to eq 'cleanname'
        expect(obj.dirname).to eq '.'
        expect(obj.extname).to eq '.jpg'
        expect(obj.author).to eq 'ANB'
        expect(obj.date_time).to eq DateTime.strptime('20131130-183657', '%Y%m%d-%H%M%S')
        expect(obj.basename_is_standard?).to be true
      end
      fcl02 = '20131130-183657_ANB cleanname.jpg'
      it "when I change all parts of the #{fcl01}" do
        obj = FTools::FTFile.new(fcl02)
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
    describe 'and updates inner state' do
      fcl03 = '20131130-183657_ANB cleanname.jpg'
      it "when I just clean the name for #{fcl03}" do
        obj = FTools::FTFile.new(fcl03)
        expect(obj.cleanse!).to eq './cleanname.jpg'
        expect(obj.basename).to eq 'cleanname'
        expect(obj.basename_clean).to eq 'cleanname'
        expect(obj.dirname).to eq '.'
        expect(obj.extname).to eq '.jpg'
        expect(obj.author).to be_empty
        expect(obj.date_time).to eq DateTime.new(0)
        expect(obj.basename_is_standard?).to be false
      end
      fcl04 = '20131130-183657_ANB cleanname.jpg'
      it "when I change all parts of the #{fcl04}" do
        obj = FTools::FTFile.new(fcl04)
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
    fcn01 = '20131130-183657_ANB cleanname.jpg'
    it 'when I set new dirname' do
      obj = FTools::FTFile.new(fcn01)
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
