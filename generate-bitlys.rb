#!/usr/bin/env ruby
require 'safe_yaml'
# web push stuff
require 'net/http'
require 'net/https'
require 'uri'
require 'json'

cached_bitlys = SafeYAML.load_file('.bitly_cache')
# webpush_keys = SafeYAML.load_file('.webpush_keys.yaml')

def clean_out(inp)
  return inp.gsub('Success! Here is your Bitly URL: ', '').gsub(' [copied to clipboard]', '').strip
end

def get_desc_title(base_name)
  desc = ""
  title = ""
  lang = ""
  Dir.glob("./_posts/**/*#{base_name}") { |file|
    crawl = false
    found_desc = false
    file_done = false
    File.foreach(file) { |line|
      if file_done
        return desc.gsub("\n", "").strip, title, lang
      end
      if not crawl and line.strip == "---"
        crawl = true
        found_desc = false
        desc = ""
        title = ""
      elsif crawl and line.strip == "---"
        crawl = false
        file_done = true
        #done with file
        next
      end
      if crawl
        tags = line.split(':')
        title = tags[1].strip if tags.size == 2 and tags[0] == "title"
        lang = tags[1].strip if tags.size == 2 and tags[0] == "lang"
        if found_desc
          if tags.size > 1
            next
          else
            desc += line.strip
          end
        else
          if tags.size == 2
            if tags[0] == "description"
              # Found the description, need to read the lines until done
              desc += tags[1]
              found_desc = true
            end
          end
        end
      end
    }
  }
end

def send_webpush(url, bitly)
  base_name = url.split('/').last.gsub('.html', '.md')
  webpush_keys = SafeYAML.load_file('.webpush_keys.yaml')
  desc, title, lang = get_desc_title(base_name)
  if desc and title
    uri = URI.parse('https://api.webpushr.com/v1/notification/send/segment')
    header = {
      'webpushrKey': webpush_keys['webpushrKey'],
      'webpushrAuthToken': webpush_keys['webpushrAuthToken'],
      'Content-Type': 'application/json',
    }
    data = {
      title: title,
      message: desc,
      target_url: "#{bitly}",
      segment: [lang == "nl" ? 135401 : 135402 ]
    }
    # Create the HTTP objects
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = data.to_json
    # Send the request
    res = https.request(request)
    puts "Webpush result: #{res.code} #{res.message}: #{res.body}"
  end
end

cached_bitlys.each { |url, bitly|
  if bitly == false
    bitly = %x(bitly -u https://myautisticself.nl#{url}?utm_source=webpush&utm_medium=webpush&utm_campaign=myautisticself)
    cached_bitlys[url] = clean_out(bitly)
    puts "Bitly for #{url} => #{cached_bitlys[url]}"
    puts "Sending push notification for new post!"
    send_webpush(url, bitly)
  end
}
File.open('.bitly_cache', "wb") { |f| f.puts YAML.dump(cached_bitlys) }
