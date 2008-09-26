config.gem 'hpricot', :source => "http://code.whytheluckystiff.net"
config.gem 'ultraviolet', :lib => 'uv'
config.gem 'rdiscount'

ActiveRecord::Base.send :include, HasMarkup