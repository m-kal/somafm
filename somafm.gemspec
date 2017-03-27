$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "somafm/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "somafm"
  s.version     = Somafm::VERSION
  s.authors     = ["mkal"]
  s.email       = ["mkal@localhost.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Sfm."
  s.description = "TODO: Description of Sfm."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.2"

  s.add_development_dependency "sqlite3"
end
