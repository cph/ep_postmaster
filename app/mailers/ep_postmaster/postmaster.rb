module EpPostmaster
  class Postmaster < ::ActionMailer::Base
    default from: EpPostmaster.configuration.mailer_sender || "from@example.com"

    def bounced_email(options = {})
      @to = options.fetch(:original_sender) { options.fetch(:reply_to) }
      @recipient = options.fetch(:original_recipient)
      @subject = options[:original_subject]
      @error =  options[:error]
      notification_subject = "Failed Delivery to #{@recipient}"
      notification_subject = "#{notification_subject}: #{@subject}" if @subject
      from = options.fetch(:from, self.class.default[:from])
      mail to: @to, from: from, subject: notification_subject
    end

  end
end
