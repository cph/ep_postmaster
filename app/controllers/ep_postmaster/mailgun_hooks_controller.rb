module EpPostmaster
  class MailgunHooksController < ActionController::Base
    attr_accessor :mailgun_post

    before_action :authenticate_request!, except: :test

    def bounced_email
      unless mailgun_post.bounced_email? || mailgun_post.dropped_email?
        raise WrongEndpointError, "Unexpected post from Mailgun (code: #{mailgun_post.code}, event: #{mailgun_post.event})"
      end

      deliver_bounced_email_notification
      call_bounced_email_handler if mailgun_post.undeliverable_email?
      head :no_content
    end

  private

    def authenticate_request!
      @mailgun_post = MailgunPost.new(params)
      head :unauthorized unless mailgun_post.authentic?
    end

    def deliver_bounced_email_notification
      if mailgun_post.reply_to
        options = {
          original_message: mailgun_post, # <-- should act like a Mail::Message
          reply_to: mailgun_post.reply_to,

          # REFACTOR: eventually remove these params in favor of original_message
          original_recipient: mailgun_post.recipient,
          original_subject: mailgun_post.subject,
          error: mailgun_post.error }

        EpPostmaster.configuration.deliver! Postmaster.bounced_email(options)
      else
        logger.debug "Bounced Email Notification: No sender specified when handling bounced email to #{mailgun_post.recipient}"
      end
    end

    def call_bounced_email_handler
      handler = EpPostmaster.configuration.bounced_email_handler
      if handler.respond_to?(:handle_bounced_email!)
        handler.send(:handle_bounced_email!, mailgun_post.recipient, mailgun_post)
      else
        raise RuntimeError, "Expected #{handler} to define a method: handle_bounced_email!"
      end
    end

  end
end
