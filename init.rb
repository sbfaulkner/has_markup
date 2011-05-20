config.gem 'hpricot'
config.gem 'sbfaulkner-pygmalion', :lib => 'pygmalion', :source => 'http://gems.github.com'

ActiveRecord::Base.send :include, HasMarkup