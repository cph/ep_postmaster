EpPostmaster::Engine.routes.draw do

  # Can be removed once all bounced notification stragglers have been handled; matters because of webhook url authentication
  post "mailgun/bounced_email", to: "mailgun_hooks#bounced_email"

  post "mailgun/360members_bounced_email", to: "mailgun_hooks#bounced_email"
  post "mailgun/church360_bounced_email", to: "mailgun_hooks#bounced_email"

end
