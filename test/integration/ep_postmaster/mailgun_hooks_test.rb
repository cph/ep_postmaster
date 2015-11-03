require "test_helper"

module EpPostmaster
  class MailgunHooksTest < ActionDispatch::IntegrationTest

    should "return a 401 if the signature fails authentication" do
      post "mailgun/bounced_email", bounced_email_post.merge({"signature" => "gibberish"})
      assert_response :unauthorized # 401
    end

    context "When we receive notification of a bounced email" do
      should "email a notice to the sender and return a 200" do
        post "/mailgun/bounced_email", bounced_email_post
        assert_equal "Failed Delivery to doesntexist@test.test: Original email subject", ActionMailer::Base.deliveries.first.subject
      end
    end

    context "When we receive notification of a dropped email" do
      should "email a notice to the sender and return a 200" do
        post "/mailgun/bounced_email", dropped_email_post
        assert_equal "Failed Delivery to doesntexist@test.test: Original email subject", ActionMailer::Base.deliveries.first.subject
      end
    end

    context "When we receive a notification we don't recognize" do
      should "raise an exception" do
        assert_raises WrongEndpointError do
          post "mailgun/bounced_email", bounced_email_post.merge({"code" => 250, "event" => "completed"})
        end
      end
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

      context "when mailgun post a temporarily bounced email" do
        should "skip calling the handler, but still send the email" do
          mock(@dummy_bounced_email_handler).handle_bounced_email!.never
          assert_difference "ActionMailer::Base.deliveries.size", +1 do
            post "/mailgun/bounced_email", bounced_email_post.merge("code" => 450)
          end
        end
      end

      context "When mailgun posts a bounced email without message-headers" do
        should "skip sending the failed delivery email but still call the handler" do
          mock(@dummy_bounced_email_handler).handle_bounced_email!(anything, anything)
          assert_no_difference "ActionMailer::Base.deliveries.size" do
            post "/mailgun/bounced_email", bounced_email_post.except("message-headers")
          end
        end
      end
    end

  private

    def bounced_email_post
      mailgun_posts[:bounced_email]
    end

    def dropped_email_post
      mailgun_posts[:dropped_email]
    end

  end
end
