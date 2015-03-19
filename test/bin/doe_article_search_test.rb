#!/usr/bin/env ruby

require_relative '../test_helper'
require_relative '../../bin/doe_article_search'

describe DoeArticleSearch do

  before do
    @search = DoeArticleSearch.new
  end

  it 'builds proper URL when given category' do
    url = @search.build_url 'Energy Roundtables'
    url.must_equal 'http://www.energy.gov/search/site/%2522Energy%2520Roundtables%2522?f[0]=bundle%3Aarticle'
  end

end
