#!/usr/bin/env ruby
# frozen_string_literal: true

require 'safe_yaml'
# web push stuff
require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'htmlentities'

def clean_out(inp)
  inp.gsub('Success! Here is your Bitly URL: ', '').gsub(' [copied to clipboard]', '').strip
end

def get_desc_title(base_name)
  desc = ''
  title = ''
  lang = ''
  Dir.glob("./_posts/**/*#{base_name}") do |file|
    crawl = false
    found_desc = false
    file_done = false
    File.foreach(file) do |line|
      return desc.gsub("\n", '').strip, title, lang if file_done

      if !crawl && (line.strip == '---')
        crawl = true
        found_desc = false
        desc = ''
        title = ''
      elsif crawl && (line.strip == '---')
        crawl = false
        file_done = true
        # done with file
        next
      end
      if crawl
        tags = line.split(':')
        title = tags[1].strip if (tags.size == 2) && (tags[0] == 'title')
        lang = tags[1].strip if (tags.size == 2) && (tags[0] == 'lang')
        if found_desc
          next if tags.size > 1

          desc += line.strip
        elsif (tags.size == 2) && (tags[0] == 'description')
          # Found the description, need to read the lines until done
          desc += tags[1]
          found_desc = true
        end
      end
    end
  end
end

def send_webpush(url, bitly)
  base_name = url.split('/').last.gsub('.html', '.md')
  webpush_keys = SafeYAML.load_file('.webpush_keys.yaml')
  desc, title, lang = get_desc_title(base_name)
  return unless desc && title

  uri = URI.parse('https://api.webpushr.com/v1/notification/send/segment')
  header = {
    'webpushrKey': webpush_keys['webpushrKey'].to_s,
    'webpushrAuthToken': webpush_keys['webpushrAuthToken'].to_s,
    'Content-Type': 'application/json'
  }
  coder = HTMLEntities.new
  data = {
    title: coder.encode(title),
    message: coder.encode(desc),
    target_url: bitly.to_s,
    segment: [lang == 'nl' ? '135401' : '135402']
  }
  # Create the HTTP objects
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.body = data.to_json
  # Send the request
  res = https.request(request)
  return unless res.code != '200'

  puts "Webpush result: #{res.code} #{res.message}: #{res.body}"
  raise StandardError, 'Webpush failed!'
end

cached_bitlys = SafeYAML.load_file('.bitly_cache')

cached_bitlys.each do |url, bitly|
  next unless bitly == false

  bitly = `bitly -u https://myautisticself.nl#{url}\?utm_source=webpush\&utm_medium=webpush\&utm_campaign=myautisticself`
  cached_bitlys[url] = clean_out(bitly)
  puts "Bitly for #{url} => #{cached_bitlys[url]}"
  puts 'Sending push notification for new post!'
  send_webpush(url, cached_bitlys[url])
end
File.open('.bitly_cache', 'wb') { |f| f.puts YAML.dump(cached_bitlys) }
