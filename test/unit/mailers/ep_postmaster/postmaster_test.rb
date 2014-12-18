require 'test_helper'

module EpPostmaster
  class PostmasterTest < ActionMailer::TestCase
    attr_accessor :mail
    
    context "When sending a bounced email notification, it" do
      setup do
        @mail = Postmaster.bounced_email(mailgun_post)
      end
    
      should "mention the bounced email address in the subject" do
        assert_match "doesntexist@test.test", mail.subject
      end
    
      should "send the email from the configured mailer_sender" do
        assert_equal ["automail@mydomain.com"], mail.from
      end
    
      should "send the email to the original sender of the bounced email" do
        assert_equal ["sender@test.test"], mail.to
      end
    
      should "say something in the body of the email" do
        assert_match "unable to deliver", mail.body.encoded
      end
    end

  private
    
    def mailgun_post
      MailgunPost.new(mailgun_posts[:bounced_email])
    end

  end
end
