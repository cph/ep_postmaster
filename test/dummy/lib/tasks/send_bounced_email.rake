require "ep_postmaster/dummy_params"

desc "Send a test bounced email response with letter opener."
task send_bounced_email: :environment do
  EpPostmaster::Postmaster.bounced_email(mailgun_post).deliver
end

def mailgun_post
  params = EpPostmaster::DummyParams.new(from: "automail@test.test", reply_to: "sender@test.test", to: "doesntexist@test.test", event: :bounced_email, mailgun_api_key: "key-abc123").to_params
  EpPostmaster::MailgunPost.new(params)
end
