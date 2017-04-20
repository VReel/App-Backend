class ApplicationMailer < ActionMailer::Base
  default from: ENV['DEVISE_FROM_ADDRESS'] || 'set_from_address@example.com'
  layout 'mailer'
end
