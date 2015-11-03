module EpPostmaster
  class ApiKeyMissing < RuntimeError

    def message
      "The Mailgun API Key hasn't been set. You can set it in your config block: config.mailgun_api_key = '...'"
    end

  end
end
