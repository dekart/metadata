module Metadata
  class Stylesheets < Array
    def to_html(template)
      returning "" do |html|
        self.each do |value|
        
          options = value.is_a?(Array) && value.last.is_a?(Hash) ? value.last : {}
        
          style = template.stylesheet_link_tag(*value)
      
          case options[:browser]
          when :ie
            html << "<!--[if ie]>#{style}<![endif]-->"
          when :opera
            html << template.javascript_tag("if(window.opera){document.write('#{style}')}")
          else
            html << style
          end
        end
      end
    end
    
    def to_ary
      Array.new(self)
    end
  end
  
  class Javascripts < Array
    def to_html(template)
      returning "" do |html|
        self.each do |value|
          html << template.javascript_include_tag(value)
        end
      end
    end
  end
  
  class Base
    DEFAULT_OPTIONS = {
      :join => " - "
    }
    
    attr_accessor :title, :description, :keywords, :javascripts, :stylesheets
    
    def initialize(options = {})
      options.symbolize_keys!
      
      [:title, :description, :keywords].each do |attr|
        value = options.delete(attr.to_sym)

        self.send("#{attr}=", value.is_a?(Array) ? value : [value].compact)
      end
      
      @stylesheets = Stylesheets.new(
        options[:stylesheets].is_a?(Array) ? options[:stylesheets] : [options[:stylesheets]].compact
      )
      options.delete(:stylesheets)
      
      @javascripts = Javascripts.new(
        options[:javascripts].is_a?(Array) ? options[:javascripts] : [options[:javascripts]].compact
      )
      options.delete(:javascripts)
      
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def merge(other_meta)
      other_meta = self.class.new(other_meta) if other_meta.kind_of?(Hash)
      
      [:title, :description, :keywords, :javascripts, :stylesheets].each do |value|
        send(value).push(*other_meta.send(value)) if other_meta.send(value).any?
      end
    end
    
    def to_html(template)
      returning "" do |html|
        html << template.content_tag(:title, @title * @options[:join]) if @title.any?
        html << template.tag(:meta, :name => :description, :content => @description * @options[:join]) if @description.any?
        html << template.tag(:meta, :name => :keywords, :content => @keywords * @options[:join]) if @keywords.any?
        
        html << @stylesheets.to_html(template)
        
        html << @javascripts.to_html(template)
      end
    end
    
  end
end