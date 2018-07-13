class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("mailer.active_subject")
  end

  def password_reset
    @greeting = t "mailer.password_reset"
    mail to: @user.email
  end
end
