require 'nokogiri'

module Jekyll
  module AmpIframeFilter
    # Filter for HTML twitter embeds
    # Converts elements to 'amp-tweet' and adds additional attributes
    # Parameters:
    #   input       - the content of the post

    def create_new_frame(src, w, h, doc)
      div = Nokogiri::XML::Node.new('div', doc)
      frame_node = Nokogiri::XML::Node.new('amp-iframe', doc)
      frame_node['layout'] = 'responsive'
      frame_node['sandbox'] = "allow-scripts allow-same-origin"
      frame_node['width'] = w
      frame_node['height'] = h
      frame_node['frameborder'] = 0
      frame_node['src'] = src
      div.add_child frame_node
      div
    end

    def amp_iframes(input)
      puts "Checking post for iFrames..."
      doc = Nokogiri::HTML.fragment(input);
      doc.css('iframe').each do |frame|
        puts "Generating iFrame?"
        src = frame['src']
        w = 292
        if frame['width']
          w = frame['width']
        end
        h = 345
        if frame['height']
          h = frame['height']
        end

        return create_new_frame(src, w, h, doc)
      end
      doc.to_s
    end
  end
end

Liquid::Template.register_filter(Jekyll::AmpIframeFilter)
