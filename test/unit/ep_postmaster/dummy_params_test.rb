require "test_helper"

module EpPostmaster
  class DummyParamsTest < ActiveSupport::TestCase
    attr_accessor :options, :dummy_params

    setup do
      @options = {
        to: "test@test.com",
        from: "test@test.com",
        event: :bounced_email,
        mailgun_api_key: "key-abc123" }
    end

    should "require keyword args: to:, from:, event:, mailgun_api_key:" do
      options.keys.each do |key|
        assert_raises KeyError do
          test_options = options.dup.tap { |opts| opts.delete(key) }
          DummyParams.new(test_options)
        end
      end
    end

    should "accept optional subject: keyword argument" do
      dummy_params = DummyParams.new(options.merge(subject: "New subject"))
      assert_equal "New subject", dummy_params.subject, "Expected the subject: argument to set the subject"
    end

  end
end
