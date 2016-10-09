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
