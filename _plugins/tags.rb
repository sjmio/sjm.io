module Jekyll

  class TagIndex < Page    
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag_index.html')
      self.data['tag'] = tag
      self.data['title'] = "Topic / "+tag.split.each { |x| x.capitalize! }.join(" ")+""
      
      # find siblings, aka post matching our tag
      self.data['siblings'] = Array.new
      site.posts.each do |post|
        post.data['tags'].each do |t|
          #if t == tag
            self.data['siblings'] << post
          #end
        end
      end
    end
  end

  class TagGenerator < Generator
    safe true
    
    def generate(site)
      if site.layouts.key? 'tag_index'
        dir = 'topic'
        site.tags.keys.each do |tag|
          write_tag_index(site, File.join(dir, tag.downcase.sub(" ","-")), tag)
        end
      end
    end
  
    def write_tag_index(site, dir, tag)
      index = TagIndex.new(site, site.source, dir, tag)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.pages << index
    end
  end

end