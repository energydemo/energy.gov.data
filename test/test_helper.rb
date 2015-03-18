require "minitest/autorun"
require "minispec-metadata"
require "vcr"
require "minitest-vcr"

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock
end

MinitestVcr::Spec.configure!
