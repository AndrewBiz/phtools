#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

# *****************************************************************************#
shared_examples_for 'any array_of_strings tag' do
  it "saves all-spaces input as empty string @value" do
    tag = described_class.new("   ")
    expect(tag.value).to be_empty
    expect(tag).to be_valid
  end

  it 'converts all items to strings' do
    val = ['www', 1, 3.14, Date.new(2016)]
    val_normal = ['www', '1', '3.14', '2016-01-01']
    tag = described_class.new(val)

    expect(tag.value).to match_array(val_normal)
    expect(tag).to be_valid
    expect(tag.errors).to be_empty
    expect(tag.value_invalid).to be_empty
  end

  it 'converts non-flat input array into flat array' do
    val = ['www', ['eee', 'rrr'], 'ttt', [1, [2, 3]]]
    val_normal = ['www', 'eee', 'rrr', 'ttt', '1', '2', '3']
    tag = described_class.new(val)

    expect(tag.value).to match_array(val_normal)
    expect(tag).to be_valid
    expect(tag.errors).to be_empty
    expect(tag.value_invalid).to be_empty
  end

  it 'converts all-spaces items to EMPTY strings items' do
    val = ['abc', '   ', 'def', ' ']
    val_normal = ['abc', '', 'def', '']
    tag = described_class.new(val)

    expect(tag.value).to match_array(val_normal)
    expect(tag).to be_valid
    expect(tag.errors).to be_empty
    expect(tag.value_invalid).to be_empty
  end

  context 'when gets invalid value' do
  #   example '= wrong type (String)' do
  #     val_nok = 'abcd'
  #     tag = described_class.new(val_nok)
  #     expect(tag.value).to be_empty
  #     expect(tag).not_to be_valid
  #     expect(tag.value_invalid).not_to be_empty
  #     expect(tag.value_invalid).to match_array([val_nok])
  #     expect(tag.errors.inspect).to include("wrong type (String)")
  #     expect(tag.to_write_script).to be_empty
  #   end
  #
  #   example '= wrong type (DateTime)' do
  #     val_nok = DateTime.new(2016)
  #     tag = described_class.new(val_nok)
  #     expect(tag.value).to be_empty
  #     expect(tag).not_to be_valid
  #     expect(tag.value_invalid).not_to be_empty
  #     expect(tag.value_invalid).to match_array([val_nok])
  #     expect(tag.errors.inspect).to include("wrong type (DateTime)")
  #     expect(tag.to_write_script).to be_empty
  #   end
  #
  #   example '= wrong type (Hash)' do
  #     val_nok = { aaa: 1, bbb: 2 }
  #     tag = described_class.new(val_nok)
  #     expect(tag.value).to be_empty
  #     expect(tag).not_to be_valid
  #     expect(tag.value_invalid).not_to be_empty
  #     expect(tag.value_invalid).to match_array([val_nok])
  #     expect(tag.errors.inspect).to include("wrong type (Hash)")
  #     expect(tag.to_write_script).to be_empty
  #   end
  #
  #   example '= wrong type (Fixnum)' do
  #     val_nok = 1
  #     tag = described_class.new(val_nok)
  #     expect(tag.value).to be_empty
  #     expect(tag).not_to be_valid
  #     expect(tag.value_invalid).not_to be_empty
  #     expect(tag.value_invalid).to match_array([val_nok])
  #     expect(tag.errors.inspect).to include("wrong type (Fixnum)")
  #     expect(tag.to_write_script).to be_empty
  #   end

    # example '= too big string' do
    #   tag = described_class.new(val_nok_size)
    #   expect(tag.value).to be_empty
    #   expect(tag).not_to be_valid
    #   expect(tag.value_invalid).not_to be_empty
    #   expect(tag.value_invalid).to match_array([val_nok_size])
    #   expect(tag.errors.inspect).to include("#{val_nok_size}")
    #   expect(tag.errors.inspect).to include('longer than allowed')
    #   expect(tag.to_write_script).to be_empty
    # end
  end
end
