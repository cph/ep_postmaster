EpPostmaster::Engine.routes.draw do

  post "mailgun/bounced_email", to: "mailgun_hooks#bounced_email"

end
