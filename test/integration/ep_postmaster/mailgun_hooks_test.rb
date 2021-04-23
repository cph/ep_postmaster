require "test_helper"

module EpPostmaster
  class MailgunHooksTest < ActionDispatch::IntegrationTest

    should "return a 401 if the signature fails authentication" do
      post "/mailgun/bounced_email", params: bounced_email_post.merge({"signature" => "gibberish"}), as: :json
      assert_response :unauthorized # 401
    end

    context "When we receive notification of a bounced email" do
      should "email a notice to the sender and return a 200" do
        post "/mailgun/bounced_email", params: bounced_email_post, as: :json
        assert_equal "Failed Delivery to doesntexist@test.test: Original email subject", ActionMailer::Base.deliveries.first.subject
      end
    end

    context "When we receive notification of a dropped email" do
      should "email a notice to the sender and return a 200" do
        post "/mailgun/bounced_email", params: dropped_email_post, as: :json
        assert_equal "Failed Delivery to doesntexist@test.test: Original email subject", ActionMailer::Base.deliveries.first.subject
      end
    end

    context "When we recieve a failure for sending a bounced email notification" do
      setup do
        @dummy_bounced_email_handler = Class.new { def self.handle_bounced_email!(*); end }
        EpPostmaster.configure { |config| config.bounced_email_handler = @dummy_bounced_email_handler }
      end

      should "ignore the failure" do
        mock(@dummy_bounced_email_handler).handle_bounced_email!.never
        assert_no_difference "ActionMailer::Base.deliveries.size" do
          post "/mailgun/bounced_email", params: mailgun_posts[:bounced_notification], as: :json
        end
      end
    end

    context "When we receive a notification we don't recognize" do
      should "raise an exception" do
        assert_raises WrongEndpointError do
          bounced_email = bounced_email_post
          bounced_email["event-data"]["delivery-status"]["code"] = "250"
          bounced_email["event-data"]["event"] = "completed"
          post "/mailgun/bounced_email", params: bounced_email, as: :json
        end
      end
    end

    context "When passing a block for 'mailer_sender', it" do
      setup do
        @mailer_sender_block = -> (*) { throw :abort }
        EpPostmaster.configure { |config| config.mailer_sender = @mailer_sender_block }
      end

      should "not send an email if the block throw :abort" do
        post "/mailgun/bounced_email", params: bounced_email_post, as: :json
        assert_equal 0, ActionMailer::Base.deliveries.count
      end
    end

    context "When passing a class to handle the bounced email, it" do
      setup do
        @dummy_bounced_email_handler = Class.new { def self.handle_bounced_email!(*); end }
        EpPostmaster.configure { |config| config.bounced_email_handler = @dummy_bounced_email_handler }
      end

      should "call handle_bounced_email! on the class" do
        mock(@dummy_bounced_email_handler).handle_bounced_email!(anything, anything)
        post "/mailgun/bounced_email", params: bounced_email_post, as: :json
      end

      context "when mailgun post a temporarily bounced email" do
        should "skip calling the handler, but still send the email" do
          mock(@dummy_bounced_email_handler).handle_bounced_email!.never
          assert_difference "ActionMailer::Base.deliveries.size", +1 do
            bounced_email = bounced_email_post
            bounced_email["event-data"]["delivery-status"]["code"] = "450"
            post "/mailgun/bounced_email", params: bounced_email, as: :json
          end
        end
      end

      context "When mailgun posts a bounced email without message-headers" do
        should "skip sending the failed delivery email but still call the handler" do
          mock(@dummy_bounced_email_handler).handle_bounced_email!(anything, anything)
          bounced_email = bounced_email_post
          bounced_email["event-data"]["message"] = {}
          bounced_email["event-data"]["envelope"] = {}
          assert_no_difference "ActionMailer::Base.deliveries.size" do
            post "/mailgun/bounced_email", params: bounced_email, as: :json
          end
        end
      end
    end

  private

    def bounced_email_post
      mailgun_posts[:bounced_email].deep_dup
    end

    def dropped_email_post
      mailgun_posts[:dropped_email].deep_dup
    end

  end
end
