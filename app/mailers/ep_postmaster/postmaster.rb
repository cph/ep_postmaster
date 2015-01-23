module EpPostmaster
  class Postmaster < ActionMailer::Base
    default from: EpPostmaster.configuration.mailer_sender || "from@example.com"

    def bounced_email(options = {})
      @sender = options.fetch(:sender)
      @recipient = options.fetch(:recipient)
      @original_subject = options[:subject]
      @error =  options[:error]
      subject = "Failed Delivery to #{@recipient}"
      subject = "#{subject}: #{@original_subject}" if @original_subject
      mail to: @sender, subject: subject
    end
  end
end
