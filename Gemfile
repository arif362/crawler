source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'devise', '~> 4.7', '>= 4.7.2'
gem 'jbuilder', '~> 2.7'
gem 'puma', '~> 4.1'
gem 'rails', '~> 6.0.3'
gem 'sass-rails', '>= 6'
gem 'sqlite3', '~> 1.4'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 4.0'
gem 'will_paginate', '~> 3.3'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capistrano', '~> 3.14', require: false
  gem 'capistrano3-puma', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rails-console'
  gem 'capistrano-rvm', require: false
  gem 'capistrano-yarn', require: false
  gem 'letter_opener', '~> 1.7'
end

group :development do
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
