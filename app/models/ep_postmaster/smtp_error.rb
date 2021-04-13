module EpPostmaster
  class SmtpError

    SMTP_ERROR_MESSAGE_ROLLUP = [
      "The email address is invalid or there is an issue with the recipients mailbox",
      "There is an issue with the recipients mailbox",
      "There is an issue with the recipients mail server",
      "There was a network error while delivering the email",
      "There was an error sending the message",
      "There is an issue with an attachment",
      "There was an error sending the message"
    ].freeze

    UNKNOWN_ERROR_MESSAGE = "An error occured".freeze

    # Mailgun unfortunately does not give us the enhanced status code neatly.
    # It looks like it stuffs what it gets back from the desitnation server
    # into the error field of the event record it sends via webhook.
    # This will attempt to glean the enhanced code from that message.
    # Sometimes the status code will be the enhanced code.
    def self.normalize(status_code, error, recipient)
      # 6xx is a Mailgun code, error contains the description
      return error if status_code.to_s.match(/^6/)

      # status code and the enhanced code are _supposed_ to be different, but in practice....
      status_code_pattern = /\d\d\d/
      status_code = status_code&.match(status_code_pattern)  || error&.match(status_code_pattern) || ""

      # Per RFC3463 the status code structure is <class "." subject "." detail>
      enhanced_code_pattern = /((?<class>\d)\.(?<subject>\d)\.(?<detail>\d))/
      smtp_enhanced_status_code = status_code.to_s.match(enhanced_code_pattern) || error.to_s.match(enhanced_code_pattern)

      smtp_error_subject = smtp_enhanced_status_code.nil? ? nil : smtp_enhanced_status_code[:subject].to_i

      if smtp_error_subject
        (SMTP_ERROR_MESSAGE_ROLLUP[smtp_error_subject - 1] || UNKNOWN_ERROR_MESSAGE) + " for #{recipient} (Error: #{status_code} #{smtp_enhanced_status_code})"
      else
        UNKNOWN_ERROR_MESSAGE + " for #{recipient} (Error: #{error})"
      end
    end
  end
end
