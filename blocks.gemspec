$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "no_cms/blocks/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "nocms-blocks"
  s.version     = NoCms::Blocks::VERSION
  s.authors     = ["Rodrigo Garcia Suarez", 'Fernando Fdz. Zapico', 'Luis Mendo', 'Victor Ortiz', 'David J. Brenes']
  s.email       = ['gems@simplelogica.net']
  s.homepage    = "https://github.com/simplelogica/nocms-blocks"
  s.summary     = "Engine of configurable content blocks CMS agnostic (NoCMS)."
  s.description = "This engine allow adding content blocks to other AR model with very few dependencies."

  s.files = Dir["{app,config,db,lib}/**/*", "CHANGELOG", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0", '<= 4.2.3'
  s.add_dependency "globalize", "> 4.0", '< 5.1'
  s.add_dependency "awesome_nested_set", '>= 3.0.0.rc.6'

  s.add_development_dependency "sqlite3"
end
