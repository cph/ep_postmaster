require "securerandom"

module EpPostmaster
  class DummyParams
    attr_accessor :event, :to, :from, :reply_to, :mailgun_api_key, :subject

    class UnknownEvent < ArgumentError; end

    MAILGUN_EVENTS = {
      bounced_email: { "event" => "failed", "reason" => "bounced", "delivery-status" => {"code" => "550", "error" => "550 email address does not exist" }},
      dropped_email: { "event" => "failed", "reason" => "dropped", "delivery-status" => {} }
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
      webhook_params = { "event-data" => {
          "storage" => storage_fields,
          "Message-Id" => "<#{message_id}>",
          "attachment-count" => "1",
          "message" => message_fields,
          "envelope" => envelope_fields,
          "recipient" => to,
        }.merge(MAILGUN_EVENTS[event])
      }

      webhook_params.merge!({
          "signature" => {
            "signature" => signature,
            "timestamp" => timestamp,
            "token" => token
          }
        })
    end

  private

    def domain
      from.split("@")[-1]
    end

    def message_id
      "#{SecureRandom.hex}@#{domain}"
    end

    def storage_fields
      { "url" => "https://storage-us-east4.api.mailgun.net/v3/domains/#{domain}/messages/AwAlBY7jbvwEEi3jydZARqxwooVjhSyeZQ==" }
    end

    def message_fields
      message = {}
      header_fields = {
          "to" => to,
          "from" => from,
          "subject" => subject,
          "message-id" => message_id
        }
      header_fields.merge!({"reply-to" => reply_to}) if reply_to
      message.merge!({"headers" => header_fields})
      message.merge!({"attachments" => ["attachment"], "size": 1035})
    end

    def envelope_fields
      {"sender" => from, "transport" => "smtp", "targets" => to}
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
