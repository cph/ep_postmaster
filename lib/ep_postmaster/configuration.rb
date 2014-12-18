module EpPostmaster
  class Configuration
    attr_accessor :mailgun_api_key, :mailer_sender, :bounced_email_handler
    
    def initialize
      @mailgun_api_key = ""
      @bounced_email_handler = Class.new do
        def self.handle_bounced_email(*)
          # noop
        end
      end
    end
     
  end
end
