# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "rr"
require "shoulda/context"
require "pry"
require "turn"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

# Load test data for posts from Mailgun
class ActiveSupport::TestCase

  attr_accessor :mailgun_posts
  
  setup do
    @mailgun_posts = {}.tap do |posts| 
      Dir.glob("test/mailgun_posts/**/*.yml").each do |post|
        key = File.basename(post, ".yml").parameterize("_").to_sym
        posts[key] = YAML::load(File.open(post))
      end
    end
  end
  
end
