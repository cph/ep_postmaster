module EpPostmaster
  class Configuration
    attr_accessor :mailgun_api_key, :mailer_sender
    
    def initialize
      @mailgun_api_key = ""
      self.bounced_email_handler = Class.new do
        def self.handle_bounced_email!(*)
          # noop
        end
      end
    end
    
    def bounced_email_handler=(handler)
      @__bounced_email_handler = handler
    end
    
    # constantize passed strings the first time they're called, cache the result for subsequent calls
    def bounced_email_handler
      if @__bounced_email_handler.is_a?(String)
        @__bounced_email_handler = @__bounced_email_handler.constantize
      end
      @__bounced_email_handler
    end
     
  end
end
