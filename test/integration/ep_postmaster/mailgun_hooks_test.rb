require "test_helper"

module EpPostmaster
  class MailgunHooksTest < ActionDispatch::IntegrationTest
  
    should "email a notice to the sender and return a 200" do
      post "/mailgun/bounced_email", bounced_email_post
      assert_equal "Failed Delivery to doesntexist@test.test: Original email subject", ActionMailer::Base.deliveries.first.subject
    end
  
    should "return a 401 if the signature fails authentication" do
      post "mailgun/bounced_email", bounced_email_post.merge({"signature" => "gibberish"})
      assert_response :unauthorized # 401
    end
    
    should "return a 406 if the status code is not a bounce" do  # When a Mailgun hook points toward the wrong endpoint
      any_instance_of(MailgunHooksController) do |controller|
        mock(controller).notify_airbrake(anything) { true }
      end
      post "mailgun/bounced_email", bounced_email_post.merge({"code" => 250, "event" => "completed"})
      assert_response :not_acceptable # 406
    end
    
    context "When passing a class to handle the bounced email, it" do
      
      setup do
        @dummy_bounced_email_handler = Class.new { def self.handle_bounced_email!(*); end }
        EpPostmaster.configure { |config| config.bounced_email_handler = @dummy_bounced_email_handler }
      end
      
      should "call handle_bounced_email! on the class" do
        mock(@dummy_bounced_email_handler).handle_bounced_email!(anything, anything)
        post "/mailgun/bounced_email", bounced_email_post
      end

    end
  
    
    
  
  private
  
    def bounced_email_post
      mailgun_posts[:bounced_email]
    end
  
  end
end
