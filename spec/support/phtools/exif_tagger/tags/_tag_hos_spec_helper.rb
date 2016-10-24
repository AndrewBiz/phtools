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
    # TODO: make it independent on size of tested hash
    val = [ 3.14, Date.new(2016)]
    val_normal = [ '3.14', '2016-01-01']
    val_hash = generate_hash(val_ok.keys, val)

    tag = described_class.new(val_hash)

    expect(tag.value.values).to match_array(val_normal)
    expect(tag).to be_valid
    expect(tag.errors).to be_empty
    expect(tag.value_invalid).to be_empty
  end

  # it 'converts non-flat input array into flat array' do
  #   val = ['www', ['eee', 'rrr'], 'ttt', [1, [2, 3]]]
  #   val_normal = ['www', 'eee', 'rrr', 'ttt', '1', '2', '3']
  #   tag = described_class.new(val)
  #
  #   expect(tag.value).to match_array(val_normal)
  #   expect(tag).to be_valid
  #   expect(tag.errors).to be_empty
  #   expect(tag.value_invalid).to be_empty
  # end
  #
  # it 'converts all-spaces items to EMPTY strings items' do
  #   val = ['abc', '   ', 'def', ' ']
  #   val_normal = ['abc', '', 'def', '']
  #   tag = described_class.new(val)
  #
  #   expect(tag.value).to match_array(val_normal)
  #   expect(tag).to be_valid
  #   expect(tag.errors).to be_empty
  #   expect(tag.value_invalid).to be_empty
  # end

  # context 'when gets invalid type value' do
  #   example 'with wrong type (String)' do
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
  #   example 'with wrong type (DateTime)' do
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
  #   example 'with wrong type (Array)' do
  #     val_nok = { aaa: 1, bbb: 2 }
  #     tag = described_class.new(val_nok)
  #     expect(tag.value).to be_empty
  #     expect(tag).not_to be_valid
  #     expect(tag.value_invalid).not_to be_empty
  #     expect(tag.value_invalid).to match_array([val_nok])
  #     expect(tag.errors.inspect).to include("wrong type (Array)")
  #     expect(tag.to_write_script).to be_empty
  #   end
  #
  #   example 'with wrong type (Fixnum)' do
  #     val_nok = 1
  #     tag = described_class.new(val_nok)
  #     expect(tag.value).to be_empty
  #     expect(tag).not_to be_valid
  #     expect(tag.value_invalid).not_to be_empty
  #     expect(tag.value_invalid).to match_array([val_nok])
  #     expect(tag.errors.inspect).to include("wrong type (Fixnum)")
  #     expect(tag.to_write_script).to be_empty
  #   end
  #
  #   example 'with wrong string items sizes' do
  #     tag = described_class.new((val_ok_size + val_nok_size).sort)
  #
  #     expect(tag).not_to be_valid
  #     expect(tag.value).to match_array(val_ok_size)
  #     expect(tag.value_invalid).not_to be_empty
  #     expect(tag.value_invalid).to match_array(val_nok_size)
  #
  #     val_nok_size.each do |i|
  #       expect(tag.errors.inspect).to include("'#{i}'")
  #       expect(tag.to_write_script).not_to include("#{i}")
  #     end
  #     val_ok_size.each do |i|
  #       expect(tag.errors.inspect).not_to include("'#{i}'")
  #       expect(tag.to_write_script).to include("#{i}")
  #     end
  #   end
  # end
end
