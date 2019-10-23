require 'rmagick'
include Magick

@path = 'test.png'
text = "Dit is een test voor een titel"

canvas = Image.new(400, 60) do |c|
  c.background_color= "Transparent"
end

watermark_text = Draw.new
watermark_text.annotate(canvas, 0,0,0,0, text) do
  self.gravity = CenterGravity 
  self.pointsize = 50
  self.font = "assets/css/fonts/leaguegothic-regular-webfont.ttf"
  self.fill = 'gray'
  self.stroke = "none"
end

canvas.write(@path)