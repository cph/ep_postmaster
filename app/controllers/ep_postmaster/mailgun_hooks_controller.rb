module EpPostmaster
  class MailgunHooksController < ApplicationController
    attr_accessor :mailgun_post
    
    before_filter :authenticate_request!, except: :test
    
    def bounced_email
      if mailgun_post.bounced_email?
        Postmaster.bounced_email(mailgun_post).deliver
        call_bounced_email_handler
        render nothing: true, status: 200
      else
        render nothing: true, status: 406 # Mailgun won't retry request if it receives a 406
      end
    end
    
  private
    
    def authenticate_request!
      @mailgun_post = MailgunPost.new(params)
      render nothing: true, status: :unauthorized unless mailgun_post.authentic?
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
