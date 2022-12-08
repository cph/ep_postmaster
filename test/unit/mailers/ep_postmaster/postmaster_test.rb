require 'test_helper'

module EpPostmaster
  class PostmasterTest < ActionMailer::TestCase
    attr_accessor :mail, :options

    context "When sending a bounced email notification, it" do
      setup do
        @options = { original_sender: mailgun_post.reply_to, original_recipient: mailgun_post.recipient, error: mailgun_post.error, original_subject: mailgun_post.subject }
        @mail = Postmaster.bounced_email(options)
      end


      should "send the email from the configured mailer_sender" do
        EpPostmaster.configure { |config| config.mailer_sender = "static@sender.com" }
        message = Postmaster.bounced_email(options)
        assert_equal ["static@sender.com"], message.from
      end

      should "send the email from the evaluated mailer_sender when it is a lambda" do
        EpPostmaster.configure { |config| config.mailer_sender = ->(message) { "dynamic@sender.com" } }
        message = Postmaster.bounced_email(options.merge(original_message: mailgun_post))
        assert_equal ["dynamic@sender.com"], message.from
      end

      should "override the configured mailer_sender with from: option" do
        mail_with_from_option = Postmaster.bounced_email(options.merge(from: "bot@mydomain.com"))
        assert_equal ["bot@mydomain.com"], mail_with_from_option.from
      end


      should "mention the bounced email address in the subject" do
        assert_match "doesntexist@test.test", mail.subject
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
      MailgunPost.new(mailgun_posts[:bounced_email], "dummy")
    end

  end
end
