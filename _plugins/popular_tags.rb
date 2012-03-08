module Jekyll
  class PopularTags < Liquid::Tag
    safe = true
    
    def render(context)
      frequencies = Hash.new(0)
      context.registers[:site].tags.each { |t| frequencies[t[0]] += t[1].length }
      value = Array.new
      value << "<ol class=\"popular-tags\">"
      frequencies.sort_by {|k, v| v}.reverse[0..9].each do |k, v|
        value << "<li><a href=\"/topic/#{k.downcase.sub(" ","-")}\">#{k.split.each { |x| x.capitalize! }.join(' ')}</a></li>"
      end
      value << "</ol>"
      value
    end
  end
end

Liquid::Template.register_tag('popular_tags', Jekyll::PopularTags)