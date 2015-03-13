#!/usr/bin/env ruby

require 'csv'
require 'json'

class TopicsToJson

  def process(csv_fname)
    result = {}

    csv = CSV.read(csv_fname, headers:true)

    # extract named headers
    all_headers = csv.headers
    headers = all_headers.reject(&:nil?)

    # iterate over rows
    topics = result['topics'] = []
    csv.each do |row|
      topic = {}

      # iterate over fixed headers
      headers.each do |header|
        key = header.downcase
        topic[key] = row[header]
      end

      # iterate over variable links
      links = topic['links'] = {}
      (headers.size...all_headers.size).step(2) do |ii|
        # break out of loop if linktext is nil
        break if (linktext = row[ii]).nil?

        # skip this iteration if linkurl is nil
        next if (linkurl = row[ii + 1]).nil?

        links[linktext] = linkurl
      end

      topics << topic
    end

    result
  end

end


if __FILE__ == $0 && 1 == ARGV.length
  # if there is 1 argument, invoke code on first argument

  fname = ARGV[0]
  converter = TopicsToJson.new
  obj = converter.process(fname)

  puts JSON.pretty_generate(obj)

elsif __FILE__ == $0 && 0 == ARGV.length
  # no command line arg, run unit test

  require 'minitest/autorun'

  class Test < Minitest::Test
    def setup
      fname = 'test/fixtures/topics.csv'
      @converter = TopicsToJson.new
      @res = @converter.process(fname)
    end

    def test_topics
      topics = @res['topics']

      assert_instance_of Array, topics
      assert_equal 2, topics.size

      # row 0
      row = topics.first
      assert_equal 'Energy Consumption', row['title']
      assert_equal 'img/turn_off_lights_19916160.jpg', row['image']
      assert_nil row['description']

      # row 0 variable data - hash of linktext => linkurl
      links = row['links']
      assert_instance_of Hash, links
      assert_equal 4, links.size
      assert_equal 'http://www.eia.gov/consumption/residential/',
                   links['Residential Buildings']
      assert_equal 'http://www.eia.gov/consumption/commercial/',
                   links['Commercial Buildings']
      assert_equal 'http://www.eia.gov/consumption/manufacturing/',
                   links['Industry']
      assert_equal 'http://www.eia.gov/consumption/data.cfm#vehicles',
                   links['Transportation']
    end

    def test_empty_link_url
      topics = @res['topics']
      row = topics[1]
      links = row['links']
      assert_equal ["Natural Gas", "Coal", "Petroleum", "Solar", "Wind", "Hydropower", "Nuclear", "Geothermal"],
                   links.keys
    end
  end

end
