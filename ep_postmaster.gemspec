$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ep_postmaster/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ep_postmaster"
  s.version     = EpPostmaster::VERSION
  s.authors     = ["Ben Govero"]
  s.email       = ["ben.govero@cph.org"]
  s.homepage    = "http://cph.org"
  s.summary     = "Adds an API endpoint to your Rails engine to handle bounced emails from Mailgun"
  s.description = ""

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.2.1", "< 8.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rr"
  s.add_development_dependency "shoulda-context"
  s.add_development_dependency "pry"
  s.add_development_dependency "minitest", "~> 5.1"
  s.add_development_dependency "minitest-reporters-turn_reporter"
  s.add_development_dependency "letter_opener"
  s.add_development_dependency "base64"
  s.add_development_dependency "bigdecimal"
  s.add_development_dependency "mutex_m"
  s.add_development_dependency "drb"
end
