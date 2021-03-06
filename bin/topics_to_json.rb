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
    topics = result['data'] = []
    csv.each do |row|
      topic = {}

      # iterate over fixed headers
      headers.each do |header|
        key = header.downcase
        topic[key] = row[header]
      end

      # iterate over variable links
      links = topic['links'] = []
      (headers.size...all_headers.size).step(2) do |ii|
        # break out of loop if linktext is nil
        break if (linktext = row[ii]).nil?

        # skip this iteration if linkurl is nil
        next if (linkurl = row[ii + 1]).nil?

        links << {'text'=>linktext, 'url'=>linkurl}
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
      @topics = @res['data']
    end

    def test_topics
      assert_instance_of Array, @topics
      assert_equal 2, @topics.size

      # row 0
      row = @topics.first
      assert_equal 'Energy Consumption', row['title']
      assert_equal 'img/turn_off_lights_19916160.jpg', row['image']
      assert_nil row['description']

      # row 0 variable data - hash of linktext => linkurl
      links = row['links']
      assert_instance_of Array, links
      assert_equal 4, links.size

      assert_equal 'Residential Buildings', links[0]['text']
      assert_equal 'http://www.eia.gov/consumption/residential/', links[0]['url']

      assert_equal 'Commercial Buildings', links[1]['text']
      assert_equal 'http://www.eia.gov/consumption/commercial/', links[1]['url']

      assert_equal 'Industry', links[2]['text']
      assert_equal 'http://www.eia.gov/consumption/manufacturing/', links[2]['url']

      assert_equal 'Transportation', links[3]['text']
      assert_equal 'http://www.eia.gov/consumption/data.cfm#vehicles', links[3]['url']
    end

    def test_empty_link_url
      row = @topics[1]
      links = row['links']
      linktexts = links.map {|hash| hash['text']}
      assert_equal ["Natural Gas", "Coal", "Petroleum", "Solar", "Wind", "Hydropower", "Nuclear", "Geothermal"], linktexts
    end
  end

end
