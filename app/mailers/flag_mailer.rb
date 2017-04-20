class FlagMailer < ApplicationMailer
  def admin_alert(flag)
    @flag = flag

    mail(to: ENV['MODERATOR_EMAILS'], subject: "[#{Rails.env.upcase}] Post #{flag.post.id} flagged by #{flag.user.handle}")
  end
end
