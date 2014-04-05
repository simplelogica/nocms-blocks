$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "nocms/blocks/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "nocms-blocks"
  s.version     = NoCms::Blocks::VERSION
  s.authors     = ["Rodrigo García Suárez", 'Fernando Fdz. Zapico']
  s.email       = ["rodrigo@simplelogica.net", 'fernando@simplelogica.net']
  s.homepage    = ""
  s.summary     = "Content blocks engine for noCMS."
  s.description = "This engine allow adding content blocks to other noCMS engine or render then by their own."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.4"

  s.add_development_dependency "sqlite3"
end
