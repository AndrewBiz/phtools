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

  it 'accepts DateTime value' do
    t = described_class.new(DateTime.new(2014, 07, 31, 22, 53, 10))
    expect(t).to be_valid
    expect(t.value).to eq DateTime.new(2014, 07, 31, 22, 53, 10)
    expect(t.value_invalid).to be_empty
    expect(t.to_write_script).to include('=2014-07-31 22:53:10')
  end

  it 'accepts Time value' do
    t = described_class.new(Time.new(2014, 07, 31, 22, 57, 10))
    expect(t).to be_valid
    expect(t.value).to eq Time.new(2014, 07, 31, 22, 57, 10)
    expect(t.value_invalid).to be_empty
    expect(t.to_write_script).to include('=2014-07-31 22:57:10')
  end

  it 'does not accept values of wrong type' do
    t = described_class.new(Date.new(2014, 07, 31))
    expect(t).not_to be_valid
    expect(t.value).to be_empty
    expect(t.value_invalid).not_to be_empty
    expect(t.value_invalid).to match_array([Date.new(2014, 07, 31)])
    expect(t.to_write_script).to be_empty
    expect(t.errors.inspect).to include('wrong type (Date)')
  end

  it 'does not accept too long String value' do
    val_nok = '123456789012345678901234567890123' # bytesize=33
    t = described_class.new(val_nok)
    expect(t).not_to be_valid
    expect(t.value).to be_empty
    expect(t.value_invalid).not_to be_empty
    expect(t.value_invalid).to match_array([val_nok])
    expect(t.to_write_script).to be_empty
    expect(t.errors.inspect).to include('longer than allowed')
  end

  it 'does not accept zero DateTime value' do
    val_nok = DateTime.new(0)
    t = described_class.new(val_nok)
    expect(t).not_to be_valid
    expect(t.value).to be_empty
    expect(t.value_invalid).not_to be_empty
    expect(t.value_invalid).to match_array([val_nok])
    expect(t.to_write_script).to be_empty
    expect(t.errors.inspect).to include('zero Date')
  end

  it 'does not accept zero Time value' do
    val_nok = Time.new(0)
    t = described_class.new(val_nok)
    expect(t).not_to be_valid
    expect(t.value).to be_empty
    expect(t.value_invalid).not_to be_empty
    expect(t.value_invalid).to match_array([val_nok])
    expect(t.to_write_script).to be_empty
    expect(t.errors.inspect).to include('zero Date')
  end
end
