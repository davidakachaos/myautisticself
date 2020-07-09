require 'mime/types'
require 'nokogiri'

module Jekyll
  module WebpFilter
    def forcewebp(input)
      doc = Nokogiri::HTML.fragment(input)
      doc.css('img').each do |img|
        next if img['class']&.include?('preview')
        next if img['src']&.include?('http')
        next if img['src']&.include?('gif')

        source = img['src']
        source ||= img['data-src']
        next if source.nil?

        picture = Nokogiri::XML::Node.new 'picture', doc

        # Generate new <source srcset="img path" type="image/webp"/> and add it to <picture>
        picture_webp = Nokogiri::XML::Node.new 'source', doc
        picture_webp['type'] = 'image/webp'
        # Small bugfix for jpeg files.
        picture_webp['data-srcset'] = if source.include?('.jpeg')
                                        source[0...-4] + 'webp'
                                      else
                                        source[0...-3] + 'webp'
                                      end
        picture.add_child(picture_webp)

        # Generate new <source> with original image and add it to <picture>
        picture_orig = Nokogiri::XML::Node.new 'source', doc
        picture_orig['type'] = MIME::Types.type_for(File.extname(source).delete('.'))[0].to_s
        picture_orig['data-srcset'] = source
        picture.add_child(picture_orig)

        # Copy and add <img> to <picture>
        picture_img = img.dup
        # Cheat a bit
        if picture.add_child(picture_img)
          if picture_img['class']&.include?('lazyload') == false
            picture_img['class'] ||= ''
            picture_img['class'] += ' lazyload'
            picture_img['data-src'] = picture_img['src']
            picture_img.delete('src')
          end
        end

        # Replace <img> with <picture><source/><img/></picture>
        img.replace picture
      end

      # Return the html as plaintext string
      doc.to_s
    end
  end
end

Liquid::Template.register_filter(Jekyll::WebpFilter)
