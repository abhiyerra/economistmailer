require "rubygems"
require 'open-uri'
require 'hpricot'
require 'net/smtp'
require 'smtp-tls'

FromEmail = 'bot@traytwo.com'
Password = 'BOT_EMAIL_PASSWORD'

ToEmail = 'YOUR_EMAIL'

@articles = []

def get_print_edition
  source = "http://www.economist.com/printedition/"

  doc = Hpricot(open(source))
  doc.search("div.style-2").each do |section|
    cur_section = (section/'h1').inner_html

    section.search('div.block').each do |article|
      @articles << get_article((article/'h2/a')[0].attributes['href'], cur_section)
      sleep 1
    end
  end
end

def get_article article_url, section
  doc = Hpricot(open(article_url))

  title = (doc/'//title').inner_html

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
END_MESSAGE

  msgstr
end

def send_articles
  get_print_edition

   Net::SMTP.start('smtp.gmail.com', 587, 'traytwo.com', FromEmail, Password, 'plain') do |smtp|
     @articles.each do |article|
       smtp.send_message(article, FromEmail, ToEmail)
     end
  end
end

send_articles
