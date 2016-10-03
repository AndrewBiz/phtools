#!/usr/bin/env ruby
# encoding: UTF-8
# (c) ANB Andrew Bizyaev

def get_argument(description = '')
  /^.*'(?<arg>.*)'.*$/.match(description)
  Regexp.last_match(:arg)
end
