module HasMarkup
  def self.included(base)
    base.extend ClassMethods
  end

  THEME = 'mac_classic'
  LANGUAGE = 'ruby_on_rails'
  NUMBERS = true
  
  module ClassMethods
    def has_markup(*attr_names)
      attr_names.each do |attr_name|
        before_save "self.#{attr_name}_html = self.class.markup(#{attr_name}, #{attr_name}_markup)"
        validates_inclusion_of "#{attr_name}_markup", :in => %w(HTML Markdown Plain\ text Textile), :unless => "#{attr_name}.blank?"
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
        theme = code.get_attribute(:theme) || options[:theme]
        language = code.get_attribute(:language) || options[:language]
        numbers = case code.get_attribute(:numbers)
                  when NilClass
                    options[:numbers].nil? ? NUMBERS : options[:numbers]
                  when 'numbers'
                    true
                  else
                    false
                  end

        theme = THEME if ! Uv.themes.include? theme
        language = LANGUAGE unless Uv.syntaxes.include? language

        prefix, lines = code.inner_html.match(/(\r?\n)?(.*)/m).to_a[1,2]

        code.swap "#{prefix}#{Uv.parse(lines, 'xhtml', language, numbers, theme)}"
      end
      doc.to_s
    end
  end
end