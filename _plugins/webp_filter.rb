# frozen_string_literal: true

require 'mime/types'
require 'nokogiri'

module Jekyll
  module WebpFilter
    @@file_exists_cache = {}

    def forcewebp(input)
      doc = Nokogiri::HTML.fragment(input)
      doc.css('img').each do |img|
        next if img['class']&.include?('preview') || img['src']&.include?('http') || img['src']&.include?('gif')

        source = img['src']
        source ||= img['data-src']
        next if source.nil?

        picture = create_picture(doc, img)
        img.replace picture
      end

      # Return the html as plaintext string
      doc.to_s
    end

    private

    def create_picture(doc, img)
      source = img['src']
      source ||= img['data-src']
      picture = Nokogiri::XML::Node.new 'picture', doc

      # Generate new <source srcset="img path" type="image/webp"/> and add it to <picture>
      picture_webp = Nokogiri::XML::Node.new 'source', doc
      picture_webp['type'] = 'image/webp'
      # Small bugfix for jpeg files.
      webp_source = if source.include?('.jpeg')
                      "#{source[0...-4]}webp"
                    else
                      "#{source[0...-3]}webp"
                    end

      picture_webp['data-srcset'] = "#{webp_source.gsub('/assets/img', '/assets/resized/80')} 80w, "
      picture_webp['data-srcset'] += webp_source
      picture.add_child(picture_webp)

      # /assets/img/ableist-ableism-ecard.png

      # Generate new <source> with original image and add it to <picture>
      picture_orig = Nokogiri::XML::Node.new 'source', doc
      picture_orig['type'] = MIME::Types.type_for(File.extname(source).delete('.'))[0].to_s
      # Generate link for every size....
      picture_orig['data-srcset'] = ''
      [20, 80, 250, 300, 500, 900].each do |size|
        # Only if the resized picture exists
        next unless check_file_exists(source.gsub('/assets/img', "assets/resized/#{size}"))

        picture_orig['data-srcset'] += "#{source.gsub('/assets/img', "/assets/resized/#{size}")} #{size}w, "
      end
      picture_orig['data-srcset'] += source.to_s
      picture.add_child(picture_orig)

      # Copy and add <img> to <picture>
      picture_img = img.dup
      # Cheat a bit
      # if it hasn't the lazyload, add it!
      if picture_img['class']&.include?('lazyload') == false
        picture_img['class'] ||= ''
        picture_img['class'] += ' lazyload'
        picture_img['data-src'] = picture_img['src']
        picture_img['src'] = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='
        picture_img['data-sizes'] = 'auto'
      end
      picture.add_child(picture_img)

      # Now if we have a attribution/caption for the image, add a surrounding figure tag
      # and a figcaption; https://stackoverflow.com/questions/12899691/use-of-picture-inside-figure-element-in-html5
      if img['data-attribution'].nil? # || img.has_key?('data-caption')
        # Add the picture as a child
        picture
      else
        # Replace <img> with <picture><source/><img/></picture>
        fig = Nokogiri::XML::Node.new 'figure', doc
        fig['class'] = img['class']
        fig.add_child(picture)
        # Create the figcaption
        figcap = Nokogiri::XML::Node.new 'figcaption', doc
        figcap.content = img['data-attribution']
        # Add the caption and replace <img> with <figure><picture><source/><img/></picture><figcaption></figcaption></figure>
        fig.add_child(figcap)
        fig
      end
    end

    def check_file_exists(file)
      @@file_exists_cache[file] ||= File.file?(file)
      @@file_exists_cache[file]
    end
  end
end

Liquid::Template.register_filter(Jekyll::WebpFilter)
