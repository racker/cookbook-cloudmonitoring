source 'https://rubygems.org'
 
gem 'berkshelf',  '~> 2.0'
 
group :testing do
  gem 'chefspec',   '~> 3.0'
  gem 'foodcritic', '~> 3.0'
  gem 'thor',       '~> 0.18'
  gem 'strainer',   '~> 3.3'
  gem 'chef',       '~> 11.0'
  gem 'rspec',      '~> 2.14'
#  gem 'rubocop',    '~> 0.16' 
  gem 'rubocop',    :git => 'https://github.com/RSTJNII/rubocop.git', :branch => 'gemhackery'

  # Required for this cookbook's ChefSpec tests
  gem 'fog',        '~> 1.19'
end
 
group :integration do
  gem 'test-kitchen', '~> 1.0'
  gem 'kitchen-vagrant', '~> 0.14'
end
