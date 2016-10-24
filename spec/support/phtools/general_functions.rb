#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

def get_argument(description = '')
  /^.*'(?<arg>.*)'.*$/.match(description)
  Regexp.last_match(:arg)
end

def generate_hash(keys, values)
  hash = {}
  keys.each_index do |i|
    hash[keys[i]] = values[i]
  end
  hash
end
