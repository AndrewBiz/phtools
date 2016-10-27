#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

# *****************************************************************************#
shared_examples_for 'any hash_of_strings tag' do
  it "saves all-spaces input as empty string @value" do
    tag = described_class.new("   ")
    expect(tag.value).to be_empty
    expect(tag).to be_valid
  end

  context 'when gets invalid value' do
    example 'with wrong type (String)' do
      val_nok = 'abcd'
      tag = described_class.new(val_nok)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.value_invalid).to match_array([val_nok])
      expect(tag.errors.inspect).to include("wrong type (String)")
      expect(tag.to_write_script).to be_empty
    end

    example 'with wrong type (DateTime)' do
      val_nok = DateTime.new(2016)
      tag = described_class.new(val_nok)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.value_invalid).to match_array([val_nok])
      expect(tag.errors.inspect).to include("wrong type (DateTime)")
      expect(tag.to_write_script).to be_empty
    end

    example 'with wrong type (Array)' do
      val_nok = [ '1', '2', '3' ]
      tag = described_class.new(val_nok)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.value_invalid).to match_array([val_nok])
      expect(tag.errors.inspect).to include("wrong type (Array)")
      expect(tag.to_write_script).to be_empty
    end

    example 'with wrong type (Fixnum)' do
      val_nok = 1
      tag = described_class.new(val_nok)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.value_invalid).to match_array([val_nok])
      expect(tag.errors.inspect).to include("wrong type (Fixnum)")
      expect(tag.to_write_script).to be_empty
    end

    example 'with too big string items' do
      tag = described_class.new(val_nok_size)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.errors.inspect).to include('longer than allowed')
      expect(tag.to_write_script).to be_empty
    end

    example 'hash with unknown key' do
      tag = described_class.new(val_with_unknown_key)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.errors.inspect).to include('is unknown')
      expect(tag.to_write_script).to be_empty
    end

    example 'with mandatory hash keys are missed' do
      tag = described_class.new(val_with_missed_key)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.errors.inspect).to include('is missed')
      expect(tag.to_write_script).to be_empty
    end
  end
end
