source "https://rubygems.org"

# Declare your gem's dependencies in nocms-blocks.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'

group :development, :test do
  gem 'pry-rails'
  gem 'pry-nav'
  gem 'pry-remote'
  gem 'pry-stack_explorer'

  gem 'mysql2'
end

group :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'capybara-screenshot'
  gem 'factory_girl'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'faker'
  gem 'carrierwave' # For development and testing purposes (Images)
  gem 'appraisal'
  gem 'simplecov'
  gem 'simplecov-json'
  gem "generator_spec"
end

