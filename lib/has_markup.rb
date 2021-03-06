begin
  require 'rdiscount'
  BlueCloth = RDiscount
rescue LoadError
  require 'bluecloth'
end
  
module HasMarkup
  def self.included(base)
    base.extend ClassMethods
  end
  
  MARKUP_TYPES = %w(HTML Markdown Plain\ text Textile)
  MARKUP_LANGUAGE = ''
  MARKUP_NUMBERS = true
  
  module ClassMethods
    def has_markup(*attr_names)
      attr_names.each do |attr_name|
        class_eval "def markup_#{attr_name}; self.#{attr_name}_html = self.class.markup(#{attr_name}, #{attr_name}_markup); end; protected :markup_#{attr_name}"
        before_save "markup_#{attr_name}".to_sym
        validates_inclusion_of "#{attr_name}_markup", :in => HasMarkup::MARKUP_TYPES, :unless => "#{attr_name}.blank?"
        class_eval "def #{attr_name}_text; @#{attr_name}_plain_text ||= Hpricot(#{attr_name}_html.gsub(/&[a-z]+?;/,'')).to_plain_text; end", __FILE__, __LINE__
      end
    end
    
    def markup(markup, markup_type)
      case markup_type
      when 'HTML'
        colourize(markup)
      when 'Markdown'
        BlueCloth.new(colourize(markup)).to_html
      when 'Textile'
        RedCloth.new(colourize(markup)).to_html
      else
        "<p>#{markup}</p>"
      end
    end

    def colourize(text, options = {})
      doc = Hpricot(text)
      doc.search("//code") do |code|
        language = code.get_attribute(:language) || options[:language] || HasMarkup::MARKUP_LANGUAGE
        numbers = case code.get_attribute(:numbers)
                  when NilClass
                    options[:numbers].nil? ? HasMarkup::MARKUP_NUMBERS : options[:numbers]
                  when 'numbers'
                    true
                  else
                    false
                  end

        prefix, lines = code.inner_html.match(/(\r?\n)?(.*)/m).to_a[1,2]

        code.swap "#{prefix}#{lines.highlight(:language => language, :line_numbers => numbers).gsub(/\\$/, '&not;')}"
      end
      doc.to_s
    end
  end
end
