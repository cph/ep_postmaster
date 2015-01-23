module EpPostmaster
  class MailgunHooksController < ActionController::Base
    attr_accessor :mailgun_post
    
    before_filter :authenticate_request!, except: :test
    
    def bounced_email
      if mailgun_post.bounced_email?
        deliver_bounced_email_notification
        call_bounced_email_handler
        render nothing: true, status: 200
      else
        notify_airbrake_of_wrong_endpoint("5xx (bounced)")
        render nothing: true, status: 406 # Mailgun won't retry request if it receives a 406
      end
    end
    
  private
    
    def authenticate_request!
      @mailgun_post = MailgunPost.new(params)
      render nothing: true, status: :unauthorized unless mailgun_post.authentic?
    end
    
    def deliver_bounced_email_notification
      if mailgun_post.sender
        options = { sender: mailgun_post.sender, recipient: mailgun_post.recipient, error: mailgun_post.error, subject: mailgun_post.subject }
        Postmaster.bounced_email(options).deliver
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
    
    def notify_airbrake_of_wrong_endpoint(expected)
      if respond_to?(:notify_airbrake)
        notify_airbrake WrongEndpointError.new "Expected error code #{expected}, instead got #{mailgun_post.code} (#{mailgun_post.event})"
      end
    end
    
  end
end
