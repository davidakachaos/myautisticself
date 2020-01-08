#!/usr/bin/env ruby
require 'safe_yaml'
cached_bitlys = SafeYAML.load_file('.bitly_cache')

def clean_out(inp)
  return inp.gsub('Success! Here is your Bitly URL: ', '').gsub(' [copied to clipboard]', '').strip
end

cached_bitlys.each { |url, bitly|
  if bitly == false
    bitly = %x(bitly -u http://myautisticself.nl#{url})
    cached_bitlys[url] = clean_out(bitly)
    puts "Bitly for #{url} => #{cached_bitlys[url]}"
  end
}
File.open('.bitly_cache', "wb") { |f| f.puts YAML.dump(cached_bitlys) }
