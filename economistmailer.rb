require 'rubygems'
require 'open-uri'
require 'debugger'
require 'uri'
require 'nokogiri'
require "sinatra"
require 'pocket'

enable :sessions

CALLBACK_URL = "http://localhost:4567/oauth/callback"

Pocket.configure do |config|
  config.consumer_key = '10188-3565cd04d1464e6d0e64b67f'
end


@articles = []

def get_print_edition

  client = Pocket.client(:access_token => session[:access_token])
  url = 'http://www.economist.com/printedition/'
  html = open(url)
  doc = Nokogiri::HTML(html.read)
  doc.encoding = 'utf-8'

  doc.search("div.section").each do |section|
    cur_section = (section/'h4').inner_html

    puts cur_section

    in_link = false
    links = {}
    section.elements.each do |article|
      if article.name == 'h5'
        in_link = true
        links[:text] = article.text
      elsif article.name == "div"
        in_link = false
        link = article.search('a').first
        links[:href] = link.attributes['href'].value
        links[:text] = "#{links[:text]}: #{link.text}"
        begin
          article_url = URI.join(url, links[:href]).to_s

          info = client.add :url => article_url unless links[:href].nil?
          puts info
        rescue Pocket::Error => e
          puts e
        end
      end

      pp links unless in_link
    end
  end
end


get '/reset' do
  puts "GET /reset"
  session.clear
end

get "/" do
  puts "GET /"
  puts "session: #{session}"

  if session[:access_token]
    '
<a href="/add">Add Economist</a>
    '
  else
    '<a href="/oauth/connect">Connect with Pocket</a>'
  end
end

get "/oauth/connect" do
  puts "OAUTH CONNECT"
  session[:code] = Pocket.get_code(:redirect_uri => CALLBACK_URL)
  new_url = Pocket.authorize_url(:code => session[:code], :redirect_uri => CALLBACK_URL)
  puts "new_url: #{new_url}"
  puts "session: #{session}"
  redirect new_url
end

get "/oauth/callback" do
  puts "OAUTH CALLBACK"
  puts "request.url: #{request.url}"
  puts "request.body: #{request.body.read}"
  result = Pocket.get_result(session[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = result['access_token']
  puts result['access_token']
  puts result['username']
  # Alternative method to get the access token directly
  #session[:access_token] = Pocket.get_access_token(session[:code])
  puts session[:access_token]
  puts "session: #{session}"
  redirect "/"
end

get '/add' do
  get_print_edition
end
