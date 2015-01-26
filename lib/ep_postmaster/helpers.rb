module EpPostmaster
  module Helpers
    
    def send_bounced_email_notification!(options = {})
      Postmaster.bounced_email(options).deliver
    end
    
  end
end
