require 'thread'
require 'thwait'

# based on https://github.com/juusaw/amp-jekyll/
module Jekyll
  # Defines the base class of AMP posts
  class AmpPost < Page
    def initialize(site, base, dir, post)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(site.source, '_layouts'), 'amp.html')

      self.data['body']          = replace_links_to_posts(remove_responsive_image(post.content))
      self.data['is_a_post']     = post.respond_to?('id')
      self.data['lang']          = post.data['lang']
      self.data['image']         = post.data['image']
      self.data['ref']           = post.data['ref']
      self.data['title']         = post.data['title']
      self.data['description']   = post.data['description']
      self.data['date']          = post.data['date']
      self.data['author']        = post.data['author']
      self.data['category']      = post.data['category']
      self.data['tags']          = post.data['tags']
      self.data['canonical_url'] = post.url

    end

    private

    def replace_links_to_posts(content)
      # {% post_url 2019-09-11-overprikkeling-bij-ondergevoeligheid %}
      # ->
      # /amp/2019/09/overprikkeling-bij-ondergevoeligheid
      return content.gsub(/\{\%\s{0,1}post_url.+\%\}/){ |m|
        matches = m.match(/\{\%\s{0,1}post_url (\d{4})-(\d{2})-\d{2}-(.+)\s{0,1}\%}/)
        if matches.nil?
          raise StandardError, "No matches for post? #{m.inspect}"
        end
        "/amp/#{matches[1]}/#{matches[2]}/#{matches[3]}"
      }
    end

    def remove_responsive_image(content)
      # {% responsive_image path: assets/img/identityfirst.jpg alt: "Identity first autism" title: "Identity first autism" class: 'ui image medium floated right' %}
      # ->
      # ![Mijn Pokémon Go avatar](/assets/img/profiel-pokemon.png){: class='ui image medium floated right'}
      img_string = "![xdes](url){: class=klass}"

      return content.gsub(/\{\% responsive_image.+\%\}/){ |m|
        match_pth = /path: ([a-z\/\.\-]+)/.match(m)
        match_alt = /alt: (["a-zA-Z\s]+)\s/.match(m)
        match_tit = /title: (["a-zA-Z\s]+)\s/.match(m)
        match_kls = /class: (['a-zA-Z\s]+)/.match(m)
        newstr = img_string.clone
        if match_alt.nil? && match_tit.nil?
          newstr.gsub!('xdes', "Image")
        elsif match_tit.nil?
          newstr.gsub!('xdes', match_alt[1])
        else
          newstr.gsub!('xdes', match_tit[1])
        end
        newstr.gsub!('url', "/#{match_pth[1].sub('assets/img/', 'assets/resized/250/')}")
        if match_kls.nil?
          newstr.gsub!('klass', "''")
        else
          newstr.gsub!('klass', match_kls[1])
        end
        newstr
      }
    end
  end
  # Generates a new AMP post for each existing post
  class AmpGenerator < Generator
    priority :low
    safe true

    def gather_documents(site)
      include_pages = site.config['amp_include_pages'] || false
      if include_pages
        puts "there are #{site.pages.length} pages to process"
      end

      documents = site.posts.docs.clone
      documents.concat site.pages.clone if include_pages

      return documents
    end

    def generate(site)
      puts "Called AMP?"
      dir = site.config['ampdir'] || 'amp'
      thread_count = (ENV['THREADCOUNT'] || 1).to_i

      puts "using #{thread_count} threads for processing to AMP pages"
      puts "there are #{site.posts.docs.length} articles to process"

      queue = Queue.new
      documents = gather_documents(site)
      threads = []

      documents
        .reject { |page| page.data['skip_amp'] }
        .reject { |page| page.data.has_key?('redirect_from') }
        .reject { |page| page.url.include?('.xml') }
        .reject { |page| page.url.include?('.json') }
        .reject { |page| page.url.include?('.txt') }
        .reject { |page| page.relative_path == 'redirect.html' }
        .each   { |page| queue << page }

      thread_count.times do
        threads << Thread.new do
          loop do
            break if queue.empty?
            post = queue.pop(true) rescue nil
            if post
              if post.respond_to?('id')
                index = AmpPost.new(site, site.source, File.join(dir, post.id), post)
              else
                puts "Page: #{post.inspect}"
                index = AmpPost.new(site, post.relative_path, "/#{dir}#{post.url}", post)
              end
              index.render(site.layouts, site.site_payload)
              # puts index.inspect
              index.write(site.dest)
              site.pages << index
            end
          end
          # when there is no more work, the thread will stop
        end
      end
      threads.each{|t| t.join}
      puts "all AMP documents generated"
    end
  end
end
