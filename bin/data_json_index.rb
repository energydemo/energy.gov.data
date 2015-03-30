#!/usr/bin/env ruby

require 'json'
require 'open-uri'

class DataJsonIndex

  class Formatter
    def self.tagcloud(keywords)
      normalize_tag = lambda {|tag| tag.downcase.gsub(/\W/, '-') }
      keywords.map do |key, text_identifiers|
        {
          text: text_identifiers[:text],
          tag: key,
          identifiers: text_identifiers[:identifiers],
          frequency: text_identifiers[:identifiers].size
        }
      end
    end
  end

  attr_reader :data

  def initialize(url='http://energy.gov/data.json')
    str = open(url) {|stream| stream.read}
    @data = JSON.parse(str)
  end

  def datasets
    # hash maps identifiers to datasets
    build_hash = -> do
      result = {}

      self.data['dataset'].each do |ds|
        uid = self.unique_identifier(ds)
        result[uid] = ds
      end

      result
    end

    @datasets ||= build_hash.()
  end

  def keywords
    build_hash = -> do
      result = Hash.new { Array.new }

      self.datasets.each do |uid, dataset|
        dataset['keyword'].each do |str|
          tag = self.normalize_tag(str)

          unless result.include?(tag)
            result[tag] = {:text => str, :identifiers => []}
          end
          result[tag][:identifiers] += [uid]
        end
      end

      result
    end

    @keywords ||= build_hash.()
  end
  
  def normalize_tag(str)
    str.downcase.gsub(/\W/, '-')
  end

  def unique_identifier(ds)
    {identifier: ds['identifier'], title: ds['title']}
  end

end


if __FILE__ == $0
  if 1 == ARGV.length
    indexer = DataJsonIndex.new(ARGV[0])
  else
    indexer = DataJsonIndex.new
  end

  # Descending sort by frequency w/ secondary ascending sort by name.
  # Use as argument to sort: rsorted = tag_array.sort reverse_freq
  reverse_freq = lambda {|a, b|
    (comparison = b[:frequency] <=> a[:frequency]) == 0 ?
      a[:text] <=> b[:text] :
      comparison
  }

  keyword_hash = indexer.keywords
  tag_array = DataJsonIndex::Formatter.tagcloud(keyword_hash)

  puts JSON.pretty_generate({data: tag_array})
end
