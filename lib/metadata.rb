module Metadata
  class Stylesheet
    include ERB::Util
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper

    def initialize(*options)
      @value = options
    end
    
    def options
      @value.dup.extract_options!
    end
    
    def to_html
      html = stylesheet_link_tag(*@value)
      
      return "<!--[if ie]>#{html}<![endif]-->" if options[:browser] == :ie
      return javascript_tag("if(window.opera){document.write('#{html}')}") if options[:browser] == :opera
    end
  end
  
  class Javascript
    include ERB::Util
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper
    
    def initialize(*options)
      @value = options
    end
    
    def to_html
      return javascript_tag(@value)
    end
  end
  
  class Base
    include ERB::Util
    include ActionView::Helpers::TagHelper
    
    DEFAULT_OPTIONS = {
      :join => " - "
    }
    
    attr_accessor :title, :description, :keywords, :javascripts, :stylesheets
    
    def initialize(options = {})
      options.symbolize_keys!
      
      %w(title description keywords stylesheets javascripts).each do |attr|
        value = options.delete(attr.to_sym)

        self.send("#{attr}=", value.kind_of?(Symbol) ? [value] : value.to_a)
      end
      
      @options = DEFAULT_OPTIONS.merge(options)
    end
    
    def stylesheets=(values)
      @stylesheets = values.collect {|value| Stylesheet.new(value) }
    end
    
    def javascripts=(values)
      @stylesheets = values.collect {|value| Stylesheet.new(value) }
    end

    def merge(other_meta)
      other_meta = self.class.new(other_meta) if other_meta.kind_of?(Hash)
      
      self.title        += other_meta.title
      self.description  += other_meta.description
      self.keywords     += other_meta.description
      self.stylesheets  += other_meta.stylesheets
      self.javascripts  += other_meta.javascripts
    end
    
    def to_html
      returning "" do |html|
        html << content_tag(:title, @title * @options[:join]) if @title.any?
        html << tag(:meta, :name => :description, :content => @description * @options[:join]) if @description.any?
        html << tag(:meta, :name => :keywords, :content => @keywords * @options[:join]) if @keywords.any?
        
        @stylesheets.each do |stylesheet|
          html << stylesheet.to_html
        end
        
        @javascripts.each do |javascript|
          html << javascript.to_html
        end
      end
    end
    
  end
end