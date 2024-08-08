class ApplicationMailer < ActionMailer::Base
  default from: ENV['SMTP_SENDER_ADDRESS']
  layout "mailer"
end
