require "rubygems"
require 'open-uri'
require 'uri'
require 'nokogiri'
require 'rest_client'

EconomistEmail = ''
EconomistPassword = ""

@articles = []

def get_print_edition
    url = 'http://www.economist.com/printedition/'
    f =  RestClient.post(url,
                         'source'        => 'login_payBarrier',
                         'email_address' => EconomistEmail,
                         'pword'         => EconomistPassword,
                         'save_password' => '',
                         'returnURL'     => '/printedition/index.cfm?source=login_payBarrier',
                         'cms_object_id' => 'Y',
                         'paybarrier'    => '1',
                         'logging_in'    => 'Y')

    doc = Nokogiri::HTML(f)
    doc.search("div.style-2").each do |section|
        cur_section = (section/'h1').inner_html

        puts "** #{cur_section}"
        section.search('div.block').each do |article|
            article_url = URI.join(url, (article/'h2/a')[0].attributes['href'].to_s).to_s

            article_span = (article/'span').text.strip
            article_title = (article/'h2/a').text

            title = "*** TODO #{article_title.eql?('') ? '' : "#{article_span} : "}#{article_title}"
            puts article_url
            puts title
        end
    end
end

get_print_edition
