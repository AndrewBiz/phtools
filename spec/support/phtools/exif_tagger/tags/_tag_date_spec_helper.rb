#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

require 'date'

shared_examples_for 'any date-tag' do
  it 'accepts String value' do
    t = described_class.new('now')
    expect(t).to be_valid
    expect(t.value).to eq 'now'
    expect(t.value_invalid).to be_empty
    expect(t.to_write_script).to include('=now')
  end

  it "saves all-spaces input as empty string @value" do
    tag = described_class.new("   ")
    expect(tag.value).to be_empty
    expect(tag).to be_valid
  end

  it 'accepts DateTime value' do
    tag = described_class.new(DateTime.new(2014, 07, 31, 22, 53, 10))
    expect(tag).to be_valid
    expect(tag.value).to eq DateTime.new(2014, 07, 31, 22, 53, 10)
    expect(tag.value_invalid).to be_empty
    expect(tag.to_write_script).to include('=2014-07-31 22:53:10')
  end

  it 'accepts Time value and transforms it to DateTime' do
    tag = described_class.new(Time.new(2014, 07, 31, 22, 57, 10))
    expect(tag).to be_valid
    expect(tag.value).to be_a DateTime
    expect(tag.value.strftime('%F %T')).to eq DateTime.new(2014, 07, 31, 22, 57, 10).strftime('%F %T')
    expect(tag.value_invalid).to be_empty
    expect(tag.to_write_script).to include('=2014-07-31 22:57:10')
  end

  it 'accepts ZERO DateTime value and transforms it to EMPTY value' do
    tag = described_class.new(DateTime.new(0))
    expect(tag).to be_valid
    expect(tag.value).to be_empty
    expect(tag.value_invalid).to be_empty
    expect(tag.to_write_script).to be_empty
  end

  it 'accepts ZERO Time value and transforms it to EMPTY value' do
    tag = described_class.new(Time.new(0))
    expect(tag).to be_valid
    expect(tag.value).to be_empty
    expect(tag.value_invalid).to be_empty
    expect(tag.to_write_script).to be_empty
  end

  context 'when gets invalid value' do
    example '= too big string' do
      tag = described_class.new(val_nok_size)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.value_invalid).to match_array([val_nok_size])
      expect(tag.errors.inspect).to include("#{val_nok_size}")
      expect(tag.errors.inspect).to include('longer than allowed')
      expect(tag.to_write_script).to be_empty
    end

    example '= wrong type (Array)' do
      val_nok = ['abcd']
      tag = described_class.new(val_nok)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.value_invalid).to match_array([val_nok])
      expect(tag.errors.inspect).to include("wrong type (Array)")
      expect(tag.to_write_script).to be_empty
    end

    example '= wrong type (Hash)' do
      val_nok = { aaa: 1, bbb: 2 }
      tag = described_class.new(val_nok)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.errors.inspect).to include("wrong type (Hash)")
      expect(tag.to_write_script).to be_empty
    end

    example '= wrong type (Date)' do
      val_nok = Date.new(2016)
      tag = described_class.new(val_nok)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.value_invalid).to match_array([val_nok])
      expect(tag.errors.inspect).to include("wrong type (Date)")
      expect(tag.to_write_script).to be_empty
    end

    example '= wrong type (Integer)' do
      val_nok = 1
      tag = described_class.new(val_nok)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.value_invalid).to match_array([val_nok])
      expect(tag.errors.inspect).to include("wrong type (Integer)")
      expect(tag.to_write_script).to be_empty
    end
  end
end
