require "rubygems"
require 'open-uri'
require 'uri'
require 'nokogiri'

@articles = []

def get_print_edition
  puts "<html><head><title>Economist</title></head><body>"

  url = 'http://www.economist.com/printedition/'
  html = open(url)
  doc = Nokogiri::HTML(html.read)
  doc.encoding = 'utf-8'

  doc.search("div.style-2").each do |section|
    cur_section = (section/'h1').inner_html

    puts "<h1>#{cur_section}</h1>"

    section.search('div.block').each do |article|
      article_url = URI.join(url, (article/'h2/a')[0].attributes['href'].to_s).to_s

      article_span = (article/'span').text.strip
      article_title = (article/'h2/a').text

      $stderr.puts article_title

      get_article(article_url)
      sleep 1
    end
  end

  puts "</body></html>"
end

def get_article(url)
  html = open(url)
  doc = Nokogiri::HTML(html.read)

  doc.search("#ec-article-body").each do |section|
    %w{.share-links-header .related-items}.each do |class_name|
      section.search(class_name).remove
    end

    #TODO: Add this again.
    section.xpath('.//img').each do |img|
      img_src = img.attributes['src'].value
      file = "compile/#{img_src.split('/').last}"
      img.set_attribute('src', file)
      `cd compile && wget #{img_src}`
    end

    puts section.inner_html.strip
  end
end

get_print_edition

#get_article("http://www.economist.com/node/18229412?story_id=18229412")
