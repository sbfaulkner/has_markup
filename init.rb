config.gem 'hpricot', :source => 'http://code.whytheluckystiff.net'
config.gem 'sbfaulkner-pygmalion', :lib => 'pygmalion', :source => 'http://gems.github.com'

ActiveRecord::Base.send :include, HasMarkup