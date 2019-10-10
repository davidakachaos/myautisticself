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
      self.read_yaml(File.join(base, '_layouts'), 'amp.html')

      self.data['body']          = remove_responsive_image(post.content)
      self.data['lang']          = post.data['lang']
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
        newstr.gsub!('url', "/#{match_pth[1].sub('assets/img/', 'assets/resized/300/')}")
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
    def generate(site)
      puts "Called AMP?"
      dir = site.config['ampdir'] || 'amp'

      thread_count = (ENV['THREADCOUNT'] || 8).to_i

      puts "using #{thread_count} threads for processing to AMP pages"
      puts "there are #{site.posts.docs.length} articles to process"

      queue = Queue.new
      threads = []

      site.posts.docs
        .reject { |post| post.data['skip_amp'] }
        .each   { |post| queue << post }

      thread_count.times do
        threads << Thread.new do
          loop do
            break if queue.empty?
            post = queue.pop(true) rescue nil
            if post
              index = AmpPost.new(site, site.source, File.join(dir, post.id), post)
              index.render(site.layouts, site.site_payload)
              puts index.inspect
              index.write(site.dest)
              site.pages << index
            end
          end
          # when there is no more work, the thread will stop
        end
      end
      threads.each{|t| t.join}
      puts "all AMP posts generated"
    end
  end
end