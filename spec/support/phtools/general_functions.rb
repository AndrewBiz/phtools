#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

def get_argument(description = '')
  /^.*'(?<arg>.*)'.*$/.match(description)
  Regexp.last_match(:arg)
end

def generate_test_hash(keys, vals)
  hash = {}
  factor = keys.size / vals.size + 1
  val_arr = vals * factor
  keys.each_index do |i|
    hash[keys[i]] = val_arr[i]
  end
  hash
end

def generate_test_array(example_array, target_size)
  result = []
  factor = target_size / example_array.size + 1
  val_arr = example_array * factor
  target_size.times do |i|
    result[i] = val_arr[i]
  end
  result
end
