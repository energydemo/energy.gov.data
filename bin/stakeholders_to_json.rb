#!/usr/bin/env ruby

require 'csv'
require 'json'

class StakeholdersToJson

  def process(csv_fname)
    csv = CSV.read(csv_fname, headers:true)

    # extract named headers
    all_headers = csv.headers
    headers = all_headers.reject(&:nil?)

    # organize return result
    result = {'stakeholders' => []}

    # iterate over rows
    current_category = nil
    current_stakeholder = nil
    csv.each do |row|
      # edge case of starting a new stakeholder
      if current_category != row['CATEGORY']
        current_stakeholder = {
          'category' => row['CATEGORY'],
          'links'    => []
        }
        result['stakeholders'] << current_stakeholder

        current_category = row['CATEGORY']
      end

      # add links to stakeholder
      link = {}
      %w(DESCRIPTION LINKTEXT LINKURL).each {|head| link[head.downcase] = row[head] }
      current_stakeholder['links'] << link
    end

    result
  end

end


if __FILE__ == $0 && 1 == ARGV.length
  # if there is 1 argument, invoke code on first argument

  fname = ARGV[0]
  converter = StakeholdersToJson.new
  obj = converter.process(fname)

  puts JSON.pretty_generate(obj)

elsif __FILE__ == $0 && 0 == ARGV.length
  # no command line arg, run unit test

  require 'minitest/autorun'

  class Test < Minitest::Test
    def setup
      fname = 'test/fixtures/stakeholders.csv'
      @converter = StakeholdersToJson.new
      @res = @converter.process(fname)
    end

    def test_stakeholders
      stakeholders = @res['stakeholders']

      assert_instance_of Array, stakeholders
      assert_equal 5, stakeholders.size

      # row 0
      row = stakeholders.first
      assert_equal 'Homeowners', row['category']

      # row 0 variable data - hash of {description:..., linktext:..., linkurl:...}
      links = row['links']
      assert_instance_of Array, links
      assert_equal 5, links.size

      lnk = links[0]
      assert_equal 'Get your energy usage data from your local utility', lnk['description']
      assert_equal 'Green Button Energy Usage Data', lnk['linktext']
      assert_equal 'https://cms.doe.gov/data/green-button', lnk['linkurl']

      lnk = links[4]
      assert_equal 'Find out if your state offers energy efficiency incentives',
                   lnk['description']
      assert_equal 'DSIRE', lnk['linktext']
      assert_equal 'http://www.dsireusa.org/', lnk['linkurl']
    end
  end

end
