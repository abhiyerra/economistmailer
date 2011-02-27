require "rubygems"
require 'open-uri'
require 'uri'
require 'nokogiri'
require 'rest_client'

@articles = []

def get_print_edition
  url = 'http://www.economist.com/printedition/'
  f =  RestClient.get(url)

  puts "<html><head><title>Economist</title></head>"

  doc = Nokogiri::HTML(f)
  doc.search("div.style-2").each do |section|
    cur_section = (section/'h1').inner_html

    puts "<h1>#{cur_section}</h1>"

    section.search('div.block').each do |article|
      article_url = URI.join(url, (article/'h2/a')[0].attributes['href'].to_s).to_s

      article_span = (article/'span').text.strip
      article_title = (article/'h2/a').text

      get_article(article_url)
      sleep 1
    end
  end

  puts "</html>"
end

def get_article(url)
  f = RestClient.get(url)
  doc = Nokogiri::HTML(f)

  doc.search("#ec-article-body").each do |section|
    %w{.share-links-header .related-items}.each do |class_name|
      section.search(class_name).each do |node|
        node.remove
      end
    end

    puts section.inner_html.strip
  end
end

get_print_edition
