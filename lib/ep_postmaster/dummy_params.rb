require "securerandom"

module EpPostmaster
  class DummyParams
    attr_accessor :event, :to, :from, :reply_to, :mailgun_api_key, :subject
    
    class UnknownEvent < ArgumentError; end
    
    MAILGUN_EVENTS = {
      bounced_email: { "event" => "bounced", "code" => "550", "error" => "550 email address does not exist" },
      dropped_email: { "event" => "dropped" }
    }.freeze
    
    def initialize(options = {})
      @event = options.fetch(:event)
      @to = options.fetch(:to)
      @from = options.fetch(:from)
      @reply_to = options[:reply_to]
      @mailgun_api_key = options.fetch(:mailgun_api_key)
      @subject = options.fetch(:subject, "Original email subject")
      unless MAILGUN_EVENTS.has_key?(event)
        raise UnknownEvent, "Unknown event: #{event}"
      end
    end
    
    def to_params
      { "Message-Id" => "<#{message_id}>",
        "X-Mailgun-Sid" => x_mailgun_sid,
        "attachment-count" => "1",
        "domain" => domain,
        "message-headers" => message_headers,
        "message-id" => message_id,
        "recipient" => to,
        "signature" => signature,
        "timestamp" => timestamp,
        "token" => token,
        "attachment-1" => "ATTACHMENT" }.merge(MAILGUN_EVENTS[event])
    end
    
  private
    
    def message_id
      "#{SecureRandom.hex}@#{domain}"
    end
    
    def x_mailgun_sid
      SecureRandom.base64
    end
    
    def domain
      from.to_s.split(/@/).last
    end
    
    def message_headers
      reply_to_json = reply_to ? "[\"Reply-To\", \"#{reply_to}\"]," : ""
      "[[\"Received\", \"from #{domain} by mxa.mailgun.org with ESMTP id 54903636.7fe3701e8650-in2; #{date.httpdate}\"], [\"Date\", \"#{date.httpdate}\"], [\"From\", \"#{from}\"], #{reply_to_json} [\"To\", \"#{to}\"], [\"Message-Id\", \"<#{message_id}>\"], [\"Subject\", \"#{subject}\"], [\"Mime-Version\", \"1.0\"], [\"Content-Type\", [\"text/plain\", {\"charset\": \"UTF-8\"}]], [\"Content-Transfer-Encoding\", [\"7bit\", {}]], [\"X-Mailgun-Sid\", \"#{x_mailgun_sid}\"], [\"Sender\", \"#{from}\"]]"
    end
    
    def signature
      MailgunPost.sign(timestamp, token, mailgun_api_key)
    end
    
    def timestamp
      date.to_i.to_s
    end
    
    def date
      @date ||= Time.now
    end
    
    def token
      @token ||= SecureRandom.hex(32)
    end
    
  end
end
