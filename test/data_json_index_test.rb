require_relative 'test_helper'
require_relative '../data_json_index'

describe DataJsonIndex, vcr: {re_record_interval: 86400} do

  before do
    @index = DataJsonIndex.new
  end

  it 'returns 1040 datasets' do
    data = @index.data
    data.must_be_instance_of Hash

    ds = @index.datasets
    ds.must_be_instance_of Hash
    ds.size.must_equal 1040
  end

  it 'returns 2778 uniq keywords' do
    keyword_table = @index.keywords
    keyword_table.keys.size.must_equal 2778

    keyword, identifiers = keyword_table.first
    identifiers.must_be_instance_of Array
  end

  it 'returns unique identifier for a dataset' do
    dataset = @index.datasets.values.first
    @index.unique_identifier(dataset).must_equal(
      {
        identifier: 'http://en.openei.org/doe-opendata/dataset/f0000000-abcd-4372-a567-000000000472',
        title: 'Brady Geothermal 1D seismic velocity model'
      }
    )
  end

end
