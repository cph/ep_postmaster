module EpPostmaster
  class Postmaster < ActionMailer::Base
    default from: EpPostmaster.configuration.mailer_sender || "from@example.com"

    def bounced_email(mailgun_post)
      @bounced_email = mailgun_post
      mail to: mailgun_post.sender, subject: "Could not deliver email to #{mailgun_post.recipient}"
    end
  end
end
