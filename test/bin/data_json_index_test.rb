#!/usr/bin/env ruby

require_relative '../test_helper'
require_relative '../../bin/data_json_index'

describe DataJsonIndex, vcr: {re_record_interval: 86400} do

  before do
    @index = DataJsonIndex.new
  end

  # artifact of using VCR: separate examples are glommed into one to
  # create only one VCR cassette
  #
  it 'returns 1040 datasets' do
    data = @index.data
    data.must_be_instance_of Hash

    set = @index.datasets
    set.must_be_instance_of Hash
    set.size.must_equal 1040

    # returns unique identifier for a dataset
    dat0 = set.values.first
    @index.unique_identifier(dat0).must_equal(
      {
        identifier: 'http://en.openei.org/doe-opendata/dataset/f0000000-abcd-4372-a567-000000000472',
        title: 'Brady Geothermal 1D seismic velocity model'
      }
    )

    # returns 2589 unique normalized tags'
    keyword_table = @index.keywords
    keyword_table.keys.size.must_equal 2589

    keyword, value = keyword_table.first
    keyword.must_equal 'brady-s-geothermal-field'

    value.must_be_instance_of Hash
    value[:text].must_equal "Brady-s Geothermal Field"

    identifiers = value[:identifiers]
    identifiers.must_be_instance_of Array
    identifiers.size.must_equal 2
    
    identifiers[0][:title].must_equal 'Brady Geothermal 1D seismic velocity model'
    identifiers[1][:title].must_equal 'Value of Information References'
    
    # test Formatter
    tags = DataJsonIndex::Formatter.tagcloud(keyword_table)
    tg0 = tags.first
    tg0[:tag].must_equal 'brady-s-geothermal-field'
    tg0[:text].must_equal 'Brady-s Geothermal Field'
    tg0[:identifiers].must_be_instance_of Array
    tg0[:identifiers].size.must_equal 2
    tg0[:frequency].must_equal 2
    
    # test normalize_tag method
    tag = @index.normalize_tag("Brady's Geothermal Field")
    tag.must_equal 'brady-s-geothermal-field'
  end

end
