module EpPostmaster
  class Postmaster < ActionMailer::Base
    default from: EpPostmaster.configuration.mailer_sender || "from@example.com"

    def bounced_email(mailgun_post)
      @bounced_email = mailgun_post
      mail to: mailgun_post.sender, subject: "Failed Delivery to #{mailgun_post.recipient}: #{mailgun_post.subject}"
    end
  end
end
