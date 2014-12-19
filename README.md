### EP Postmaster

**A drop in solution for handling bounced emails from Mailgun**

Usage: In your `gemfile`

`gem ep_postmaster, github: "/concordia-publishing-house/ep_postmaster", branch: "master"`

and mount it in `routes.rb`

`mount EpPostmaster::Engine => "/api/postmaster"`

### Setup

You'll need to add the `api_key` from mailgun along with the default address to send emails from. To do that, create a file in `/config/initializers` (ep_postmaster.rb in our case).

```
EpPostmaster.configure do |config|
  config.mailgun_api_key = "MAILGUN_API_KEY"
  config.mailer_sender = "AUTO@MYAPP.COM"
end
```

#### Overriding Default Mail Views

To override the mailer view, just create a file at `/views/ep_postmaster/postmaster/bounced_email.txt.erb`

You'll have access to an instance variable named `@bounced_email` which is an instance of `MailgunPost`.

It has the following attributes:

* sender    (The original sender of the email that bounced back)
* recipient (The original recipient of the email that bounced back)
* code      (The error code)

(for a full list of attributes received from Mailgun, look at the source of mailgun_post.rb)

### Additional options when a Bounced Email comes in

In your `/config/initializers/ep_postmaster.rb` file, you can specify an object or class that will handle the bounced email notice after the notification has been sent. To do that, set the `bounced_email_handler` param:

```
EpPostmaster.configure do |config|
  config.mailgun_api_key = "MAILGUN_API_KEY"
  config.mailer_sender = "AUTO@MYAPP.COM"
  config.bounced_email_handler = EmailAddress
end
```

Then, on the EmailAddress class, define a class level method called `handle_bounced_email!`. This method should accept two arguments: the recipient that bounced back, and the MailgunPost object with all params sent back from Mailgun.

Example:

```
class EmailAddress
...
  def self.handle_bounced_email!(email, mailgun_post)
    find_by(address: email).update_attribute(:undeliverable, true)
  end
...
end
```
