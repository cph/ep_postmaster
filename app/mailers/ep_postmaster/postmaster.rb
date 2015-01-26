module EpPostmaster
  class Postmaster < ActionMailer::Base
    default from: EpPostmaster.configuration.mailer_sender || "from@example.com"

    def bounced_email(options = {})
      @sender = options.fetch(:original_sender)
      @recipient = options.fetch(:original_recipient)
      @subject = options[:original_subject]
      @error =  options[:error]
      notification_subject = "Failed Delivery to #{@recipient}"
      notification_subject = "#{notification_subject}: #{@subject}" if @subject
      from = options.fetch(:from, self.class.default[:from])
      mail to: @sender, from: from, subject: notification_subject 
    end
  end
end
