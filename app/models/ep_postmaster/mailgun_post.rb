require "openssl"

module EpPostmaster
  class MailgunPost
    attr_reader :message_id, :x_mailgun_sid, :code, :message_headers, :domain, :error, :event, :recipient, :sender, :signature, :timestamp, :token
    
    def initialize(params)
      @message_id = params["message-id"]
      @x_mailgun_sid = params["X-Mailgun-Sid"]
      @code = params.fetch("code")
      @message_headers = JSON.parse(params["message-headers"])
      @domain = params["domain"]
      @error = params["error"]
      @event = params["event"]
      @recipient = params.fetch("recipient")
      @sender = find_sender(params["message-headers"])
      @signature = params["signature"]
      @timestamp = params["timestamp"]
      @token = params["token"]
    end

    # Verifies that the post came from Mailgun
    # Taken from http://documentation.mailgun.com/user_manual.html#webhooks
    def authentic?
      digest = OpenSSL::Digest::SHA256.new
      data = [timestamp, token].join
      signature == OpenSSL::HMAC.hexdigest(digest, api_key, data)
    end
    
    def bounced_email?
      sender.present? && recipient.present? && code == "550"
    end
    
    def api_key
      EpPostmaster.configuration.mailgun_api_key
    end

  private

    def find_sender(headers)
      message_headers.select { |header| header[0] == "From" }.first[1]
    end
  
  end
end
