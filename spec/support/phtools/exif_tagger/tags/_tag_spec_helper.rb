#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

shared_examples_for 'any tag' do
  it 'knows it\'s own exiftool tag name' do
    expect(described_class::EXIFTOOL_TAGS).not_to be_empty
  end

  it 'gets info and puts it into write_script for exiftool' do
    tag.info = "Here I describe usefull info about this tag"
    expect(tag.to_write_script).to include('# INFO: Here I describe usefull info about this tag')
  end

  context 'when gets the correct input value' do
    subject { described_class.new(val_ok) }
    its(:value) { should eql(val_ok) }
    its(:to_s) { should include(val_ok.to_s) }
    it { should be_valid }
    its(:errors) { should be_empty }
    its(:value_invalid) { should be_empty }
    its(:warnings) { should be_empty }
  end

  it 'prevents its properties to be modified' do
    expect(tag.value).to be_frozen
    expect(tag.value_invalid).to be_frozen
    expect(tag.errors).to be_frozen
    expect(tag.warnings).to be_frozen
    expect(tag.raw_values).to be_frozen
    expect(tag.type).to be_frozen
  end
end

shared_examples_for 'any tag with MiniExiftool hash input' do
  context 'when gets correct mini_exiftool hash' do
    subject { described_class.new(mhash) }

    before(:example) do
      allow(mhash).to receive(:[]) { |tag| hash_ok[tag] }
    end

    it "works well with its test-double" do
      expect(mhash.class).to eq MiniExiftool
      hash_ok.each do |tag, value|
        expect(mhash[tag]).to eq value
      end
    end

    it "accepts input MiniExiftool hash" do
      expect(subject.value).to eq val_ok
      expect(subject.to_s).to include(val_ok.to_s)
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.warnings).to be_empty
    end

    it "keeps raw_values" do
      hash_ok.each do |tag, value|
        expect(subject.raw_values[tag]).to eq value
      end
    end
  end
end

shared_examples_for 'any_string_tag' do
  it 'knows it\'s type' do
    expect(tag.type).to be :string
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

    example '= wrong type (DateTime)' do
      val_nok = DateTime.new(2016)
      tag = described_class.new(val_nok)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.value_invalid).to match_array([val_nok])
      expect(tag.errors.inspect).to include("wrong type (DateTime)")
      expect(tag.to_write_script).to be_empty
    end

    example '= wrong type (Hash)' do
      val_nok = { aaa: 1, bbb: 2 }
      tag = described_class.new(val_nok)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.value_invalid).to match_array([val_nok])
      expect(tag.errors.inspect).to include("wrong type (Hash)")
      expect(tag.to_write_script).to be_empty
    end

    example '= wrong type (Fixnum)' do
      val_nok = 1
      tag = described_class.new(val_nok)
      expect(tag.value).to be_empty
      expect(tag).not_to be_valid
      expect(tag.value_invalid).not_to be_empty
      expect(tag.value_invalid).to match_array([val_nok])
      expect(tag.errors.inspect).to include("wrong type (Fixnum)")
      expect(tag.to_write_script).to be_empty
    end
  end
end

shared_examples_for 'any paranoid tag' do
  context 'when the original value exists' do
    it 'generates warnings' do
      tag.check_for_warnings(original_values: val_orig)
      expect(tag.warnings).not_to be_empty
      expect(tag.warnings.inspect).to include('has original value:')
    end
    context 'AND force_write is set to FALSE' do
      it 'generates write_script with WARNINGs and _commented_ lines' do
        tag.check_for_warnings(original_values: val_orig)
        tag.force_write = false
        expect(tag.to_write_script).to include('# -')
        expect(tag.to_write_script).to match(/# WARNING: ([\w]*) has original value:/)
      end
    end
    context 'AND force_write is set to TRUE' do
      it 'generates write_script with WARNINGs and _UNcommented_ lines' do
        tag.check_for_warnings(original_values: val_orig)
        tag.force_write = true
        expect(tag.to_write_script).not_to include('# -')
        expect(tag.to_write_script).to match(/# WARNING: ([\w]*) has original value:/)
      end
    end
  end
end
