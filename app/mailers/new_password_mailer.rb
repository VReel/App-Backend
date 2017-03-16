class NewPasswordMailer < DeviseMailer
  def new_password(user, new_password)
    @user = user
    @new_password = new_password

    mail(from: Devise.mailer_sender, to: @user.email, subject: 'Your new password')
  end
end
