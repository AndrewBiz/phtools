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

  it 'converts all hash items to strings' do
    a_raw = [ 3.14, Date.new(2016), 'str' ]
    a_normal = [ '3.14', '2016-01-01', 'str' ]
    val_hash = generate_test_hash(val_ok.keys, a_raw)
    val_array_normal = generate_test_array(a_normal, val_ok.keys.size)

    tag = described_class.new(val_hash)

    expect(tag.value.values).to match_array(val_array_normal)
    expect(tag).to be_valid
    expect(tag.errors).to be_empty
    expect(tag.value_invalid).to be_empty
  end

  it 'converts all-spaces items to EMPTY strings items' do
    a_raw = [ '   ', 'str' ]
    a_normal = [ '', 'str' ]
    val_hash = generate_test_hash(val_ok.keys, a_raw)
    val_array_normal = generate_test_array(a_normal, val_ok.keys.size)

    tag = described_class.new(val_hash)

    expect(tag.value.values).to match_array(val_array_normal)
    expect(tag).to be_valid
    expect(tag.errors).to be_empty
    expect(tag.value_invalid).to be_empty
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
