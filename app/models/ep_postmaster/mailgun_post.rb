require "openssl"

module EpPostmaster
  class MailgunPost
    attr_accessor :message_id, :x_mailgun_sid, :code, :message_headers, :domain, :error, :event, :recipient, :reply_to, :subject, :signature, :timestamp, :token, :from, :sender

    def initialize(params)
      @message_id = params["message-id"]
      @x_mailgun_sid = params["X-Mailgun-Sid"]
      @code = params["code"]
      @message_headers = JSON.parse(params["message-headers"]) rescue {}
      @domain = params["domain"]
      @error = params["error"]
      @event = params["event"]
      @recipient = params.fetch("recipient")
      @reply_to = find_reply_to
      @subject = find_subject
      @from = Array(message_headers.select { |header| header[0] == "From" }.first)[1]
      @sender = Array(message_headers.select { |header| header[0] == "Sender" }.first)[1]
      @signature = params["signature"]
      @timestamp = params["timestamp"]
      @token = params["token"]
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

    def bounced_email?
      /^5[\.\d]+$/ =~ code
    end

    def dropped_email?
      event == "dropped"
    end

    def api_key
      EpPostmaster.configuration.mailgun_api_key
    end

  private

    def find_reply_to
      reply_to = message_headers.select { |header| header[0] == "Reply-To" }.first
      from = message_headers.select { |header| header[0] == "From" }.first
      Array(reply_to || from)[1]
    end

    def find_subject
      Array(message_headers.select { |header| header[0] == "Subject" }.first)[1]
    end

  end
end
