# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require File.expand_path("../../lib/ep_postmaster/dummy_params.rb",  __FILE__)
require "rr"
require "pry"
require "shoulda/context"
require "minitest/reporters/turn_reporter"

if ENV["CI"] == "true"
  Minitest::Reporters.use! [ Minitest::Reporters::TurnReporter.new, Minitest::Reporters::JUnitReporter.new ]
else
  Minitest::Reporters.use! Minitest::Reporters::TurnReporter.new
end

Rails.backtrace_cleaner.remove_silencers!

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

# Load test data for posts from Mailgun
class ActiveSupport::TestCase
  attr_accessor :mailgun_posts

  setup do
    @mailgun_posts = {
      bounced_email: EpPostmaster::DummyParams.new(
        from: "automail@test.test",
        reply_to: "sender@test.test",
        to: "doesntexist@test.test",
        event: :bounced_email,
        mailgun_api_key: "key-abc123").to_params,
      dropped_email: EpPostmaster::DummyParams.new(
        from: "automail@test.test",
        reply_to: "sender@test.test",
        to: "doesntexist@test.test",
        event: :dropped_email,
        mailgun_api_key: "key-abc123").to_params,
      bounced_notification: EpPostmaster::DummyParams.new(
        from: "noreply@someserver.relay.com",
        to: "somesender@test.test",
        event: :bounced_email,
        mailgun_api_key: "key-abc123").to_params }

    EpPostmaster.configure do |config|
      config.mailgun_api_key = "key-abc123"
      config.mailer_sender = "automail@mydomain.com"
    end
  end

end
