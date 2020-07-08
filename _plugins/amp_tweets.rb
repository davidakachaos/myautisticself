require 'nokogiri'

module Jekyll
  module AmpTweetFilter
    # Filter for HTML twitter embeds
    # Converts elements to 'amp-tweet' and adds additional attributes
    # Parameters:
    #   input       - the content of the post

    def create_tweet(id, w, h, doc)
      div = Nokogiri::XML::Node.new('div', doc)
      tweet_node = Nokogiri::XML::Node.new('amp-twitter', doc)
      tweet_node['layout'] = 'responsive'
      tweet_node['data-tweetid'] = id
      tweet_node['width'] = w
      tweet_node['height'] = h
      div.add_child tweet_node
      div
    end

    def get_new_twitter_content(link, w, h, doc)
      if link =~ /twitter\.com\/.*[status|statuses]\/(\d+)/
        tweet_id = Regexp.last_match(1)
        # puts "replacing element for tweet #{tweet_id}"
        create_tweet tweet_id, w, h, doc
      end
    end

    def amp_tweets(input)
      doc = Nokogiri::HTML.fragment(input)
      doc.css('.jekyll-twitter-plugin').each do |tw|
        links = tw.css('.twitter-tweet').css('a').map { |l| l['href'] }

        w = 292
        w = tw['data-width'] if tw['data-width']
        h = 345
        h = tw['data-height'] if tw['data-height']

        tw.children.remove

        links.map { |l| get_new_twitter_content(l, w, h, doc) }
             .compact
             .each { |nte| tw.add_child(nte) }
      end
      doc.to_s
    end
  end
end

Liquid::Template.register_filter(Jekyll::AmpTweetFilter)
