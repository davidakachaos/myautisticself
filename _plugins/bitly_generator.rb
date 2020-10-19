# require 'thwait'

# based on https://github.com/juusaw/amp-jekyll/
module Jekyll
  # Generates a new bitly url for each existing post if needed
  class BitlyGenerator < Generator
    priority :low
    safe true

    def gather_documents(site)
      include_pages = site.config['bitly_include_pages'] || false
      puts "there are #{site.pages.length} pages to process" if include_pages

      documents = site.posts.docs.clone
      documents.concat site.pages.clone if include_pages

      documents
    end

    def generate(site)
      if ENV['JEKYLL_ENV'] != 'production'
        puts 'Skipping Bitly url generation'
        return
      end
      puts 'Generating Bitly URLs for posts...'
      File.open('.bitly_cache', 'wb') { |f| f.puts YAML.dump({}) } unless File.exist?('.bitly_cache')
      cached_bitlys = SafeYAML.load_file('.bitly_cache') || {}

      puts "Known bitly urls: #{cached_bitlys.keys.length}"
      puts "there are #{site.posts.docs.length} articles to process"

      queue = Queue.new
      documents = gather_documents(site)

      documents
        .reject { |page| page.data['skip_amp'] }
        .reject { |page| page.data.has_key?('redirect_from') }
        .reject { |page| page.url.include?('.xml') }
        .reject { |page| page.url.include?('.json') }
        .reject { |page| page.url.include?('.txt') }
        .reject { |page| page.relative_path == 'redirect.html' }
        .each   { |page| queue << page }

      loop do
        break if queue.empty?

        post = begin
                 queue.pop(true)
               rescue StandardError
                 nil
               end
        next unless post

        cached_bitlys[post.url] = false unless cached_bitlys.key?(post.url)
      end
      File.open('.bitly_cache', 'wb') { |f| f.puts YAML.dump(cached_bitlys) }
      puts 'all Bitly Urls queued for generation'
    end
  end
end
