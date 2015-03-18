require 'json'
require 'open-uri'

class DataJsonIndex

  class Formatter
    def self.tagcloud(keywords)
      normalize_tag = lambda {|tag| tag.downcase.gsub(/\W/, '-') }
      keywords.map do |key, id_array|
        {
          text: key,
          tag: normalize_tag.(key),
          frequency: id_array.size
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
        dataset['keyword'].each do |kw|
          result[kw] += [uid]
        end
      end

      result
    end

    @keywords ||= build_hash.()
  end

  def unique_identifier(ds)
    {identifier: ds['identifier'], title: ds['title']}
  end

end


if __FILE__ == $0
  indexer = DataJsonIndex.new
  keyword_hash = indexer.keywords
  tag_array = DataJsonIndex::Formatter.tagcloud(keyword_hash)
  reverse_sorted = tag_array.sort {|a, b|
    (comparison = b[:frequency] <=> a[:frequency]) == 0 ?
      a[:text] <=> b[:text] :
      comparison
  }
  puts JSON.pretty_generate({data: reverse_sorted})
end
