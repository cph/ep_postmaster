require "openssl"

module EpPostmaster
  class MailgunPost

    VALID_EVENTS = %w(failed rejected).freeze

    attr_accessor :message_id, :code, :message_headers, :error, :event, :recipient, :reply_to, :subject, :signature, :timestamp, :token, :from, :sender, :reason

    def initialize(params)
      event_data = params["event-data"] || {}
      @message_headers = event_data.dig("message","headers") || {}
      envelope = event_data["envelope"] || {}
      signature_data = params["signature"] || {}
      delivery_status = event_data["delivery-status"]

      @message_id = event_data["message-id"]
      @code = delivery_status["code"].to_s
      @error = get_error_message(delivery_status)
      @reason = event_data["reason"]
      @event = event_data["event"]
      @recipient = event_data.fetch("recipient")
      @subject = message_headers["subject"]
      header_from = message_headers["from"] || nil
      bracketed_from = header_from ? header_from.match(/(<(?<from>.*)>)/) : nil
      extracted_from = bracketed_from ? bracketed_from[:from] : header_from
      @from = extracted_from ? extracted_from.split("@")[0].gsub("+","@") : nil
      @sender = header_from
      @reply_to = message_headers["reply-to"] || from
      @timestamp = signature_data["timestamp"]
      @token = signature_data["token"]
      @signature = signature_data["signature"]
    rescue ActionController::ParameterMissing => e
      raise EpPostmaster::ParameterMissing, e.message
    end

    def self.sign(timestamp, token, api_key)
      digest = OpenSSL::Digest::SHA256.new
      data = [timestamp, token].join
      OpenSSL::HMAC.hexdigest(digest, api_key, data)
    end

    # Verifies that the post came from Mailgun
    # Taken from http://documentation.mailgun.com/user_manual.html#webhooks
    def authentic?
      raise ApiKeyMissing if api_key.nil?
      signature == self.class.sign(timestamp, token, api_key)
    end

    def valid_event?
      VALID_EVENTS.include?(event)
    end

    def bounced_email?
      reason == "bounced"
    end

    def undeliverable_email?
      /^5[\.\d]+$/ =~ code.to_s
    end

    def dropped_email?
      reason == "dropped"
    end

    def get_error_message(delivery_status)
      # We might get both fields, but only one should have text
      message = delivery_status["message"].to_s.strip
      description = delivery_status["description"].to_s.strip

      message.empty? ? description : message
    end

    def api_key
      EpPostmaster.configuration.mailgun_api_key
    end
  end
end
