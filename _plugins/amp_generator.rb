require 'thwait'
require 'jekyll-twitter-plugin'
# c

# based on https://github.com/juusaw/amp-jekyll/
module Jekyll
  # Defines the base class of AMP posts
  class AmpPost < Page
    attr_reader :amp

    def amp
      true
    end

    def initialize(site, base, dir, post)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      # Bestandnaam goed zetten
      process(@name)
      # Data van schijf inlezen in structure.
      read_yaml(File.join(site.source, '_layouts'), 'amp.html')

      template = (Liquid::Template.parse replace_iframes(replace_links_to_posts(remove_responsive_image(post.content))))

      data['body']          = template.render!(site.site_payload,
        { strict_variables: false, strict_filters: true, registers: { amp: true, site: site } }
      )
      data['is_a_post']     = post.respond_to?('id')
      data['lang']          = post.data['lang']
      data['image']         = post.data['image']
      data['ref']           = post.data['ref']
      data['title']         = post.data['title']
      data['description']   = post.data['description']
      data['date']          = post.data['date']
      data['author']        = post.data['author']
      data['category']      = post.data['category']
      data['tags']          = post.data['tags']
      data['canonical_url'] = post.url

      # Call trigger?
      Jekyll::Hooks.trigger :pages, :post_init, self
    end

    private

    def replace_links_to_posts(content)
      # {% post_url /2019/2019-09-11-overprikkeling-bij-ondergevoeligheid %}
      # ->
      # /amp/2019/09/overprikkeling-bij-ondergevoeligheid
      content.gsub(/\{\%\s{0,1}post_url.+\%\}/) do |m|
        matches = m.match(/\{\%\s{0,1}post_url ((?:\/\d{4}\/)?\d{4})-(\d{2})-\d{2}-(.+)\s{0,1}\%}/)
        raise StandardError, "No matches for post? #{m.inspect}" if matches.nil?

        "/amp/#{matches[1]}/#{matches[2]}/#{matches[3]}"
      end
    end

    def replace_iframes(content)
      # <iframe src="https://anchor.fm/autcast/embed" height="102px" width="400px" frameborder="0" scrolling="no"></iframe>
      content.gsub(/\<iframe.+\<\/iframe>/) do |m|
        m.gsub!('<iframe ', '<iframe sandbox="allow-scripts allow-same-origin" layout="responsive" ')
        m.gsub!('iframe', 'amp-iframe')
        m
      end
    end

    def remove_responsive_image(content)
      # {% responsive_image path: assets/img/identityfirst.jpg alt: "Identity first autism" title: "Identity first autism" class: 'ui image medium floated right' %}
      # ->
      # ![Mijn Pokémon Go avatar](/assets/img/profiel-pokemon.png){: class='ui image medium floated right'}
      img_string = '![xdes](url){: class=klass}'

      content.gsub(/\{\% responsive_image.+\%\}/) do |m|
        match_pth = /path: ([a-zA-Z0-9\/\.\-]+)/.match(m)
        match_alt = /alt: (["a-zA-Z\s]+)\s/.match(m)
        match_tit = /title: (["a-zA-Z\s]+)\s/.match(m)
        match_kls = /class: (['a-zA-Z\s]+)/.match(m)
        newstr = img_string.clone
        if match_alt.nil? && match_tit.nil?
          newstr.gsub!('xdes', 'Image')
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
      end
    end
  end
  # Generates a new AMP post for each existing post
  class AmpGenerator < Generator
    priority :low
    safe true

    def gather_documents(site)
      include_pages = site.config['amp_include_pages'] || false
      puts "there are #{site.pages.length} pages to process" if include_pages

      documents = site.posts.docs.clone
      documents.concat site.pages.clone if include_pages

      documents
    end

    def generate(site)
      # if site.config['serving']
      #   puts "AMP pages not generated when running `jekyll serve`."
      #   return
      # end
      dir = site.config['ampdir'] || 'amp'
      thread_count = (ENV['THREADCOUNT'] || 8).to_i
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

            post = begin
                     queue.pop(true)
                   rescue StandardError
                     nil
                   end
            next unless post

            if post.respond_to?('id')
              begin
                index = AmpPost.new(site, site.source, File.join(dir, post.id), post)
              rescue StandardError
                puts "Error processing: #{post.inspect}"
                raise $!
              end
            else
              index = AmpPost.new(site, post.relative_path, "/#{dir}#{post.url}", post)
            end
            index.render(site.layouts, site.site_payload)
            # puts index.inspect
            index.write(site.dest)
            site.pages << index
          end
          # when there is no more work, the thread will stop
        end
      end
      threads.each { |t| t.join }
      puts 'all AMP documents generated'
    end
  end
end
