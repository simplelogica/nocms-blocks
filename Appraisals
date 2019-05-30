ruby_version = Gem::Version.new(RUBY_VERSION)

# In Ruby 2.4 some incompatibility wth numeric types was created that affected
# Rails 4.0 and 4.1 making them unable to run
# More info: https://stackoverflow.com/questions/41504106/ruby-2-4-and-rails-4-stack-level-too-deep-systemstackerror
ruby_2_4 = Gem::Version.new('2.4.0')

# Rails 6 demands ruby over 2.4.4
ruby_2_4_4 = Gem::Version.new('2.4.4')

# Globalize latest version (5.3.0) demands ruby over 2.4.6. We need to force
# another version in prior versions
ruby_2_4_6 = Gem::Version.new('2.4.6')

if ruby_version < ruby_2_4

  appraise "rails-4-0-mysql" do
    gemspec
    gem "mysql2", "~> 0.3.10"
    gem "rails", "4.0.13"
    gem 'rspec-rails', '3.5.0'
  end

  appraise "rails-4-1-mysql" do
    gemspec
    gem "mysql2", "~> 0.3.13"
    gem "rails", "4.1.16"
    gem 'rspec-rails', '~> 3.5.0.beta'
  end

end

appraise "rails-4-2-mysql" do
  gemspec
  gem "mysql2"
  gem "rails", "4.2.11.1"
  gem 'rspec-rails', '~> 3.5.0.beta'
  if ruby_version < ruby_2_4_6
    gem 'globalize', '~> 5.2.0'
  end
end

appraise "rails-5-0-mysql" do
  gemspec
  gem "mysql2"
  gem 'rails', '5.0.7.2'
  gem "awesome_nested_set", '~> 3.1.1'
  gem 'rspec-rails'
  if ruby_version < ruby_2_4_6
    gem 'globalize', '~> 5.2.0'
  end
end

appraise "rails-5-1-mysql" do
  gemspec
  gem "mysql2"
  gem 'rails', '5.1.7'
  gem 'rspec-rails'
  if ruby_version < ruby_2_4_6
    gem 'globalize', '~> 5.2.0'
  end
end

appraise "rails-5-2-mysql" do
  gemspec
  gem "mysql2"
  gem 'rails', '5.2.3'
  gem 'rspec-rails'
  if ruby_version < ruby_2_4_6
    gem 'globalize', '~> 5.2.0'
  end
end

if ruby_version > ruby_2_4_4
  appraise "rails-6-rc-mysql" do
    gemspec
    gem "mysql2"
    gem 'awesome_nested_set', git: 'git@github.com:collectiveidea/awesome_nested_set.git'
    gem 'actionpack', '6.0.0.rc1'
    gem 'rails', '6.0.0.rc1'
    gem 'rspec-rails'
  end
end

if ruby_version < ruby_2_4

  appraise "rails-4-0-pgsql" do
    gemspec
    gem "pg", '~> 0.21.0'
    gem "rails", "4.0.13"
    gem 'rspec-rails', '~> 3.5.0.beta'
  end

  appraise "rails-4-1-pgsql" do
    gemspec
    gem "pg", '~> 0.21.0'
    gem "rails", "4.1.16"
    gem 'rspec-rails', '~> 3.5.0.beta'
  end
end

appraise "rails-4-2-pgsql" do
  gemspec
  gem "pg", '~> 0.21.0'
  gem "rails", "4.2.11.1"
  gem 'rspec-rails', '~> 3.5.0.beta'
  if ruby_version < ruby_2_4_6
    gem 'globalize', '~> 5.2.0'
  end
end

appraise "rails-5-0-pgsql" do
  gemspec
  gem "pg"
  gem 'rails', '5.0.7.2'
  gem "awesome_nested_set", '~> 3.1.1'
  gem 'rspec-rails'
  if ruby_version < ruby_2_4_6
    gem 'globalize', '~> 5.2.0'
  end
end

appraise "rails-5-1-pgsql" do
  gemspec
  gem "pg"
  gem 'rails', '5.1.7'
  gem 'rspec-rails'
  if ruby_version < ruby_2_4_6
    gem 'globalize', '~> 5.2.0'
  end
end

appraise "rails-5-2-pgsql" do
  gemspec
  gem "pg"
  gem 'rails', '5.2.3'
  gem 'rspec-rails'
  if ruby_version < ruby_2_4_6
    gem 'globalize', '~> 5.2.0'
  end
end

if ruby_version > ruby_2_4_4
  appraise "rails-6-rc-pgsql" do
    gemspec
    gem "pg"
    gem 'rails', '6.0.0.rc1'
    gem 'actionpack', '6.0.0.rc1'
    gem 'activemodel', '6.0.0.rc1'
    gem 'activerecord', '6.0.0.rc1'
    gem 'activesupport', '6.0.0.rc1'
    gem 'railties', '6.0.0.rc1'
    gem 'awesome_nested_set', git: 'git@github.com:collectiveidea/awesome_nested_set.git'
    gem 'rspec-rails'
  end
end

if ruby_version < ruby_2_4

  appraise "rails-4-0-sqlite" do
    gemspec
    gem "sqlite3", '~> 1.3.13'
    gem "rails", "4.0.13"
    gem 'rspec-rails', '~> 3.5.0.beta'
  end

  appraise "rails-4-1-sqlite" do
    gemspec
    gem "sqlite3", '~> 1.3.13'
    gem "rails", "4.1.16"
    gem 'rspec-rails', '~> 3.5.0.beta'
  end

end

appraise "rails-4-2-sqlite" do
  gemspec
  gem "sqlite3", '~> 1.3.13'
  gem "rails", "4.2.11.1"
  gem 'rspec-rails', '~> 3.5.0.beta'
  if ruby_version < ruby_2_4_6
    gem 'globalize', '~> 5.2.0'
  end
end

appraise "rails-5-0-sqlite" do
  gemspec
  gem "sqlite3", '~> 1.3.13'
  gem 'rails', '5.0.7.2'
  gem "awesome_nested_set", '~> 3.1.1'
  gem 'rspec-rails'
  if ruby_version < ruby_2_4_6
    gem 'globalize', '~> 5.2.0'
  end
end

appraise "rails-5-1-sqlite" do
  gemspec
  gem "sqlite3"
  gem 'rails', '5.1.7'
  gem 'rspec-rails'
  if ruby_version < ruby_2_4_6
    gem 'globalize', '~> 5.2.0'
  end
end

appraise "rails-5-2-sqlite" do
  gemspec
  gem "sqlite3"
  gem 'rails', '5.2.3'
  gem 'rspec-rails'
  if ruby_version < ruby_2_4_6
    gem 'globalize', '~> 5.2.0'
  end
end

if ruby_version > ruby_2_4_4
  appraise "rails-6-rc-sqlite" do
    gemspec
    gem "sqlite3"
    gem 'rails', '6.0.0.rc1'

    gem 'actionpack', '6.0.0.rc1'
    gem 'activemodel', '6.0.0.rc1'
    gem 'activerecord', '6.0.0.rc1'
    gem 'activesupport', '6.0.0.rc1'
    gem 'railties', '6.0.0.rc1'
    gem 'awesome_nested_set', git: 'git@github.com:collectiveidea/awesome_nested_set.git'
    gem 'rspec-rails'
  end
end
