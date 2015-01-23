require "ep_postmaster/dummy_params"

desc "Send a test bounced email response with letter opener."
task send_bounced_email: :environment do
  EpPostmaster::Postmaster.bounced_email(options).deliver
end

def options
  { sender: "automail@test.test",
    recipient: "doesntexist@test.test",
    error: "551: Email doesn't exist.",
    subject: "This is a test subject" }
end
