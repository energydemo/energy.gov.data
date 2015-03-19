#!/usr/bin/env ruby

require 'json'
require 'nokogiri'
require 'open-uri'

class DoeArticleSearch
  # return search result of phrases as JSON string
  #
  def generate_search_json(phrases)
    JSON.pretty_generate( { data: self.search(phrases) } )
  end

  # return array of search results
  #
  def search(phrases)
    threads = phrases.map {|ph| Thread.new { self.search_category(ph) }}
    array   = threads.map {|th| th.value }
  end

  # return hash of {category:String, links:Array}
  #
  def search_category(cat)
    url = self.build_url(cat)
    str = open(url).read
    doc = Nokogiri::HTML.parse str
    set = doc.css ".title a"
    arr = set.collect do |node|
      {
        linktext: node.text,
        linkurl: node['href']
      }
    end

    {
      category: cat,
      links: arr
    }
  end

  # return correctly escaped URL for energy.gov Drupal
  #
  def build_url(cat)
    quoted = "\"#{cat}\""
    escaped = self.escape_non_chars(quoted)
    "http://www.energy.gov/search/site/#{escaped}?f[0]=bundle%3Aarticle"
  end

  def escape_non_chars(str)
    str.gsub(/\W/) {|char| "%25#{char.ord.to_s(16)}" }
  end

end


if __FILE__ == $0
  search = DoeArticleSearch.new
  puts search.generate_search_json ARGV
end
