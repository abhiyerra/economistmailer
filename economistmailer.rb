require "rubygems"
require 'open-uri'
require 'nokogiri'
require 'net/smtp'
require 'rest_client'
#require 'smtp-tls'

FromEmail = ''
Password = ''

ToEmail = ''

EconomistEmail = ''
EconomistPassword = ''

@articles = []

def get_print_edition
  url = 'http://www.economist.com/printedition/index.cfm'
  f =  RestClient.post(url, 
                       'source' => 'login_payBarrier', 
                       'email_address' => EconomistEmail, 
                       'pword' => EconomistPassword, 
                       'save_password' => '', 
                       'returnURL' => '/printedition/index.cfm?source=login_payBarrier', 
                       'cms_object_id' => 'Y', 
                       'paybarrier' => '1', 
                       'logging_in' => 'Y')

  doc = Nokogiri::HTML(f)
  doc.search("div.style-2").each do |section|
    cur_section = (section/'h1').inner_html

    section.search('div.block').each do |article|
      article_url = (article/'h2/a')[0].attributes['href']

      @articles << get_article(article_url, cur_section)
      puts article_url
    end
  end
end

def get_article article_url, section
  doc = Nokogiri::HTML(open(article_url))

  title = (doc/'//title').inner_html
  title = title.gsub('| The Economist', '')

  article = (doc/'div.col-left')
  (article/"script").remove
  (article/"noscript").remove
  (article/"style").remove
  (article/"#add-comment-container").remove

  article = article.inner_html

  msgstr = <<END_MESSAGE
From: Economist Bot <#{FromEmail}>
To: #{ToEmail}
Subject: #{title} (#{section})
Content-Type: text/html; charset="us-ascii"

#{article}

<a href="#{article_url}">Article</a>
END_MESSAGE

  msgstr
end

def send_articles
  get_print_edition

  smtp = Net::SMTP.new 'smtp.gmail.com', 587 
  smtp.enable_starttls_auto
  smtp.start('traytwo.com', FromEmail, Password, 'plain') do |smtp|
    @articles.each do |article|
      smtp.send_message(article, FromEmail, ToEmail)
    end
  end
end

send_articles
