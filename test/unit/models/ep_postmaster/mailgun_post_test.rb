require "test_helper"

module EpPostmaster
  class MailgunPostTest < ActiveSupport::TestCase
    attr_accessor :mailgun_post
  
    setup do
      @mailgun_post = MailgunPost.new(mailgun_posts[:bounced_email])
    end
  
    should "get the recipient's email address" do
      assert_equal "doesntexist@test.test", mailgun_post.recipient
    end
  
    should "get the sender's email address from the message headers' 'Reply-To' field" do
      assert_equal "sender@test.test", mailgun_post.sender
    end
    
    should "get the sender's email address from the message headers' 'From' field if 'Reply-To' is nil" do
      params = DummyParams.new(from: "automail@test.test", to: "doesntexist@test.test", event: :bounced_email, mailgun_api_key: "key-abc123").to_params
      no_reply_to = MailgunPost.new(params)
      assert_equal "automail@test.test", no_reply_to.sender
    end
    
    should "get the subject from the message headers" do
      assert_equal "Original email subject", mailgun_post.subject
    end
  
    should "get the status code" do
      assert_equal "550", mailgun_post.code
    end
  
    should "get the event" do
      assert_equal "bounced", mailgun_post.event
    end
  
    should "verify the post by generating a signature and comparing it to the post's signature" do
      assert mailgun_post.authentic?
    end
  
    should "verify the post is a bounced email notification by checking the error number" do
      # Anything 5xx error code is considered a hard bounce
      assert mailgun_post.bounced_email?
      mailgun_post.code = "501"
      assert mailgun_post.bounced_email?
      mailgun_post.code = "450"
      refute mailgun_post.bounced_email?
    end
  
  end
end
