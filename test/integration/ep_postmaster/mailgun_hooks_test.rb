require "test_helper"

module EpPostmaster
  class MailgunHooksTest < ActionDispatch::IntegrationTest
  
    should "return a 401 if the signature fails authentication" do
      mailgun_post = mailgun_posts[:bounced_email]
      mailgun_post["signature"] = "gibberish"
      post "mailgun/bounced_email", mailgun_post
      assert_response :unauthorized # 401
    end
    
    should "return a 406 if the status code is not a bounce" do
      mailgun_post = mailgun_posts[:bounced_email]
      mailgun_post["code"] = 501
      post "mailgun/bounced_email", mailgun_post
      assert_response :not_acceptable # 406
    end
  
    should "email a notice to the sender and return a 200" do
      handler = Class.new { def self.handle_bounced_email(*); end }
      EpPostmaster.configure { |config| config.bounced_email_handler = handler }
      mock(handler).handle_bounced_email(anything, anything)
      post "/mailgun/bounced_email", mailgun_posts[:bounced_email]
      assert_equal "Could not deliver email to doesntexist@test.test", ActionMailer::Base.deliveries.first.subject
    end
  
  end
end
