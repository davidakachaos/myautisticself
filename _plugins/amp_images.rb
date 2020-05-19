require 'nokogiri'
require 'fastimage'

module Jekyll
  module AmpFilter

    def emoji_filtering(input)
      begin
        return Jekyll::Emoji.filter_with_emoji(Jekyll::Emoji.emoji_src).call(input)[:output].to_s
      rescue
        return input
      end
    end
    # Filter for HTML 'img' elements.
    # Converts elements to 'amp-img' and adds additional attributes
    # Parameters:
    #   input       - the content of the post
    #   responsive  - boolean, whether to add layout=responsive, true by default
    def amp_images(input, responsive = true, wi = nil, he = nil)
      # Process the emotiocons first...
      input = emoji_filtering(input)
      doc = Nokogiri::HTML.fragment(input)

      # Restructure some image tags.
      doc.css('img').each do |image|
        # Convert data-* to * because this plugin
        # uses 'src' for alterations of the image.
        if image['data-src']
          image['src'] = image['data-src']
          image.delete('data-src')
        end
        if image['data-srcset']
          image['srcset'] = image['data-srcset']
          image.delete('data-srcset')
        end

        # Remove any images that are also in a
        # noscript tag. We'll add back a noscript
        # in the proper place later.
        doc.xpath(".//noscript//img[@src=\"#{image['src']}\"]").each do |nsimg|
          nsimg.remove
        end
      end

      # Remove all empty noscript tags that could
      # happen from the removal above.
      doc.css('noscript').each do |ns|
          if ns.children.count == 0
              ns.remove
          end
      end

      # Add width and height to img elements lacking them
      doc.css('img:not([width])').each do |image|
        if wi && he
          image['width']  = wi
          image['height'] = he
        else
          if image['src'].start_with?('http://', 'https://')
            src = image['src']
          else
            # FastImage doesn't seem to handle local paths when used with Jekyll
            # so let's just force the path
            src = File.join(Dir.pwd, '_site', image['src'])
          end
          if src.include?('/posts')
            src.gsub!('/posts', '')
          end
          if src.end_with?('/')
            puts "Wrong URL given to a img!! => #{image.inspect}"
          end
          # Jekyll generates static assets after the build process.
          # This causes problems when trying to determine the dimensions of a locally stored image.
          # For now, the only solution is to skip the build and generate the AMP files after the site has beem successfully built.
          # TODO: find a better solution.
          begin
            size = FastImage.size(src)
            image['width']  = size[0]
            image['height'] = size[1]
          rescue Exception => e
            puts 'Unable to get image dimensions for "' + src + '". For local files, build the site with \'--skip-initial-build\' for better results. [Error: ' + e.to_s + ']'
            puts "org img: #{image['src']}"
          end
        end
      end
      # Change 'img' elements to 'amp-img', add responsive attribute when needed
      doc.css('img').each do |image|
        image.name = "amp-img"

        image['layout'] = "responsive" if responsive
      end

      # Picture elements are not accepted in amp pages, convert them to amp-img
      #<picture>
      #   <source srcset="mdn-logo-wide.webp" type="image/webp">
      #   <source srcset="mdn-logo-wide.png" media="(min-width: 600px)">
      #   <img src="mdn-logo-narrow.png" alt="MDN">
      #</picture>
      # Move amp-img elements inside picture elements outside of it and remove picture elements
      doc.css('picture').each do |picture|
        # Get img element from picture
        amp_img = picture.css('amp-img')
        picture.add_next_sibling(amp_img) unless amp_img.empty?

        # Remove picture element
        picture.remove
      end

      # Added <img /> tag wrapped with <noscript /> in case js is not enabled
      # but image will still show up. The element would look like this:
      # <amp-img ...>
      #    <noscript>
      #        <img ... />
      #    </noscript>
      # </ampimg ...>
      # Duplicate amp-img, remove layout attribut, wrap it with noscript, and add
      # it as amp-img child
      doc.css('amp-img').each do |amp_img|
        noscript = Nokogiri::XML::Node.new "noscript", doc

        noscript_img = amp_img.dup
        noscript_img.remove_attribute('layout')
        noscript_img.name = 'img'

        noscript.add_child(noscript_img)

        amp_img.add_child(noscript)
      end

      # Return the html as plaintext string
      doc.to_s
    end
  end
end

Liquid::Template.register_filter(Jekyll::AmpFilter)
