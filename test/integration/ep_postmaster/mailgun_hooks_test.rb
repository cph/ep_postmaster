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
      # An example of pointing a Mailgun hook toward the wrong endpoint
      mailgun_post = mailgun_posts[:bounced_email]
      mailgun_post["code"] = 250
      mailgun_post["event"] = "Completed"
      any_instance_of(MailgunHooksController) do |controller|
        mock(controller).notify_airbrake(anything) { true }
      end
      post "mailgun/bounced_email", mailgun_post
      assert_response :not_acceptable # 406
    end
  
    should "email a notice to the sender and return a 200" do
      handler = Class.new { def self.handle_bounced_email!(*); end }
      EpPostmaster.configure { |config| config.bounced_email_handler = handler }
      mock(handler).handle_bounced_email!(anything, anything)
      post "/mailgun/bounced_email", mailgun_posts[:bounced_email]
      assert_equal "Failed Delivery to doesntexist@test.test: Original email subject", ActionMailer::Base.deliveries.first.subject
    end
  
  end
end
