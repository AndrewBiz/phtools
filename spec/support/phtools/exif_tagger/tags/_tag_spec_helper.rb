#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

shared_examples_for 'any tag' do
  it 'knows it\'s ID' do
    expect(tag.tag_id).to be tag_id
    expect(tag.tag_name).to eq tag_name
  end

  it 'knows it\'s own exiftool tag name' do
    expect(described_class::EXIFTOOL_TAGS).not_to be_empty
  end

  it 'gets info and puts it into write_script for exiftool' do
    tag.info = "Here I describe usefull info about this tag"
    expect(tag.to_write_script).to include('# INFO: Here I describe usefull info about this tag')
  end

  it "saves nil input as empty string @value" do
    tag = described_class.new(nil)
    expect(tag.value).to be_empty
    expect(tag).to be_valid
  end

  it "saves TrueClass input as empty string @value" do
    tag = described_class.new(true)
    expect(tag.value).to be_empty
    expect(tag).to be_valid
  end

  it "saves FalseClass input as empty string @value" do
    tag = described_class.new(false)
    expect(tag.value).to be_empty
    expect(tag).to be_valid
  end

  context 'when gets the correct simple-type input value' do
    subject { described_class.new(val_ok) }
    it "accepts the value" do
      expect(subject.value).to eq val_ok
      expect(subject.to_s).to include(val_ok.to_s)
      expect(subject).to be_valid
      expect(subject.raw_values).to be_empty
      expect(subject.errors).to be_empty
      expect(subject.value_invalid).to be_empty
      expect(subject.warnings).to be_empty
    end
  end

  it "accepts nil as previous value" do
    tag = described_class.new(val_ok, nil)
    expect(tag.previous).to be_nil
    expect(tag.value).to eq(val_ok)
    expect(tag.to_s).to include(val_ok.to_s)
    expect(tag).to be_valid
    expect(tag.raw_values).to be_empty
    expect(tag.errors).to be_empty
    expect(tag.value_invalid).to be_empty
    expect(tag.warnings).to be_empty
  end

  it 'prevents its properties to be modified' do
    expect(tag.value).to be_frozen
    expect(tag.value_invalid).to be_frozen
    expect(tag.errors).to be_frozen
    expect(tag.warnings).to be_frozen
    expect(tag.raw_values).to be_frozen
  end
end

# *****************************************************************************#
shared_examples_for 'any tag with MiniExiftool hash input' do
  # TODO: move it to any_tag group
  context 'when gets correct mini_exiftool hash' do
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
      tag = described_class.new(mhash)

      expect(tag.raw_values).not_to be_empty
      expect(tag).to be_valid
      expect(tag.value_invalid).to be_empty
      expect(tag.errors).to be_empty
      expect(tag.warnings).to be_empty
      expect(tag.value).to eq val_ok
    end

    it "keeps raw_values" do
      tag = described_class.new(mhash)
      hash_ok.each do |t, v|
        expect(tag.raw_values[t]).to eq v
      end
    end
  end

  context 'when gets partially defined mini_exiftool hash' do
  # TODO: move it to any_tag group
    subject { described_class.new(mhash) }

    it "works well with its test-double" do
      hash = hash_ok
      allow(mhash).to receive(:[]) { |tag| hash[tag] }

      expect(mhash.class).to eq MiniExiftool
      hash.each do |tag, value|
        expect(mhash[tag]).to eq value
      end
    end

    context 'when processing raw_values' do
      it "accepts empty strings" do
        hash = hash_last_is_empty
        allow(mhash).to receive(:[]) { |tag| hash[tag] }
        last = hash.keys.last

        subject.raw_values.each do |tag, val|
          if tag == last
            expect(subject.raw_values[tag]).to be_empty
          else
            expect(subject.raw_values[tag]).to eq hash[tag]
          end
        end
      end

      it "converts all-spaces value to empty string" do
        hash = hash_last_is_all_spaces
        allow(mhash).to receive(:[]) { |tag| hash[tag] }

        last = hash.keys.last
        subject.raw_values.each do |tag, val|
          if tag == last
            expect(subject.raw_values[tag]).to be_empty
          else
            expect(subject.raw_values[tag]).to eq hash[tag]
          end
        end
      end

      it "converts nil value to empty string" do
        hash = hash_last_is_nil
        allow(mhash).to receive(:[]) { |tag| hash[tag] }
        last = hash.keys.last

        subject.raw_values.each do |tag, val|
          if tag == last
            expect(subject.raw_values[tag]).to be_empty
          else
            expect(subject.raw_values[tag]).to eq hash[tag]
          end
        end
      end

      it "converts non-defined tag to empty string" do
        hash = hash_with_nondefined
        allow(mhash).to receive(:[]) { |tag| hash[tag] }

        nondefined = (subject.raw_values.keys - hash.keys)[0]
        expect(subject.raw_values[nondefined]).to be_empty
      end

      it "converts bool value to empty string" do
        hash = hash_with_all_bool
        allow(mhash).to receive(:[]) { |tag| hash[tag] }

        subject.raw_values.each do |tag, val|
          expect(subject.raw_values[tag]).to be_empty
        end
      end

      it "is Ok with all empty raw values" do
        hash = hash_with_all_empty
        allow(mhash).to receive(:[]) { |tag| hash[tag] }

        subject.raw_values.each do |tag, val|
          expect(subject.raw_values[tag]).to be_empty
        end
        expect(subject.value).to be_empty
        expect(subject.to_s).to include('is EMPTY')
        expect(subject).to be_valid
        expect(subject.errors).to be_empty
        expect(subject.value_invalid).to be_empty
        expect(subject.warnings).to be_empty
      end
    end
  end
end

# *****************************************************************************#
shared_examples_for 'any tag who cares about previous value' do
  context 'when gets both new and previous value' do
    let(:previous_value) { described_class.new(mhash) }
    let(:tag) { described_class.new(val_ok, previous_value) }

    it "ignores previous value of wrong type (!= tag.class)" do
      tag = described_class.new(val_ok, 'string_class')

      expect(tag.previous).to be_nil
      expect(tag.value).to eq(val_ok)
      expect(tag.raw_values).to be_empty
      expect(tag.to_s).to include(val_ok.to_s)
      expect(tag).to be_valid
      expect(tag.errors).to be_empty
      expect(tag.value_invalid).to be_empty
      expect(tag.warnings).to be_empty
      expect(tag.warnings.inspect).not_to include('has original value:')
    end

    it "generates no warnings if previous.raw_values are empty" do
      allow(mhash).to receive(:[]) { |tag| val_orig_empty[tag] }

      expect(tag.previous).not_to be_nil
      expect(tag.previous.class).to eq(described_class)
      expect(tag.value).to eq(val_ok)
      expect(tag.raw_values).to be_empty
      expect(tag.to_s).to include(val_ok.to_s)
      expect(tag).to be_valid
      expect(tag.errors).to be_empty
      expect(tag.value_invalid).to be_empty
      expect(tag.warnings).to be_empty
      expect(tag.warnings.inspect).not_to include('has original value:')
    end

    it "generates warnings if previous.raw_values are not empty" do
      allow(mhash).to receive(:[]) { |tag| val_orig[tag] }

      expect(tag.previous).not_to be_nil
      expect(tag.previous.class).to eq(described_class)
      expect(tag.previous.raw_values).not_to be_empty
      expect(tag.value).to eq(val_ok)
      expect(tag.raw_values).to be_empty
      expect(tag.to_s).to include(val_ok.to_s)
      expect(tag).to be_valid
      expect(tag.errors).to be_empty
      expect(tag.value_invalid).to be_empty
      expect(tag.warnings).not_to be_empty
      expect(tag.warnings.inspect).to include('has original value:')
    end

    context 'and force_write is set to FALSE' do
      it 'generates write_script with WARNINGs and _commented_ lines' do
        allow(mhash).to receive(:[]) { |tag| val_orig[tag] }

        tag.force_write = false

        expect(tag.previous).not_to be_nil
        expect(tag.previous.class).to eq(described_class)
        expect(tag.value).to eq(val_ok)
        expect(tag.raw_values).to be_empty
        expect(tag.to_s).to include(val_ok.to_s)
        expect(tag).to be_valid
        expect(tag.errors).to be_empty
        expect(tag.value_invalid).to be_empty
        expect(tag.warnings).not_to be_empty
        expect(tag.warnings.inspect).to include('has original value:')
        expect(tag.to_write_script).to include('# -')
        expect(tag.to_write_script).to match(/# WARNING: ([\w]*) has original value:/)
      end
    end

    context 'and force_write is set to TRUE' do
      it 'generates write_script with WARNINGs and non-commented executable lines' do
        allow(mhash).to receive(:[]) { |tag| val_orig[tag] }

        tag.force_write = true

        expect(tag.previous).not_to be_nil
        expect(tag.previous.class).to eq(described_class)
        expect(tag.value).to eq(val_ok)
        expect(tag.raw_values).to be_empty
        expect(tag.to_s).to include(val_ok.to_s)
        expect(tag).to be_valid
        expect(tag.errors).to be_empty
        expect(tag.value_invalid).to be_empty
        expect(tag.warnings).not_to be_empty
        expect(tag.warnings.inspect).to include('has original value:')
        expect(tag.to_write_script).not_to include('# -')
        expect(tag.to_write_script).to match(/# WARNING: ([\w]*) has original value:/)
      end
    end
  end
end

# TODO: to remove paranoid tag
# *****************************************************************************#
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
