#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8

# (c) ANB Andrew Bizyaev

RUBY_VERSION_WANTED = '2.4.0'

begin
  fail "Ruby version must be >= #{RUBY_VERSION_WANTED}" if
    RUBY_VERSION < RUBY_VERSION_WANTED
rescue StandardError => e
  STDERR.puts e.message
  exit 1
end
