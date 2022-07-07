# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "ruby_jard"

require_relative "active_record_test_helper"
require "active_record/fixtures"
require "izolenta"
require "minitest/autorun"
