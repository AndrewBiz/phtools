#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

module ExifTagger
  # EXIF tags collection
  class TagCollection
    include Enumerable

    def initialize(init_values = nil)
      @collection = []
      unless init_values.nil?
        case
        when init_values.kind_of?(Hash)
          init_values.each do |k, v|
            self[k] = v
          end
        when init_values.kind_of?(ExifTagger::TagCollection)
          init_values.each do |item|
            self[item.tag_id] = item.value
          end
        end
      end
    end

    def each(&block)
      @collection.each(&block)
    end

    def to_s
      str = ''
      @collection.each { |i| str << i.to_s }
      str
    end

    def []=(tag, value)
      unless value.nil?
        delete(tag)
        @collection << produce_tag(tag, value.dup)
      end
    end

    def [](tag)
      ind = @collection.find_index(tag)
      ind.nil? ? nil : @collection[ind].value
    end

    def item(tag)
      ind = @collection.find_index(tag)
      ind.nil? ? nil : @collection[ind]
    end

    def delete(tag)
      @collection.delete(tag)
    end

    def valid?
      ok = true
      @collection.each { |i| ok &&= i.valid? }
      ok
    end

    def with_warnings?
      warn = false
      @collection.each { |i| warn ||= i.warnings.empty? }
      warn
    end

    def check_for_warnings(original_values: {})
      @collection.each { |i| i.check_for_warnings(original_values: original_values) }
    end

    def error_message
      str = ''
      unless valid?
        str = "Tags are NOT VALID:\n"
        @collection.each do |item|
          item.errors.each { |e| str << '    ' + e + "\n" }
        end
      end
      str
    end

    def warning_message
      str = ''
      if with_warnings?
        @collection.each do |item|
          item.warnings.each { |e| str << '    WARNING: ' + e + "\n" }
        end
      end
      str
    end

    private

    def produce_tag(tag, value)
      tag_class = ExifTagger::Tag.const_get(tag.to_s.camelize)
      tag_class.new(value)
    rescue => e
      raise ExifTagger::UnknownTag, "Tag #{tag} - #{e.message}"
    end
  end
end
