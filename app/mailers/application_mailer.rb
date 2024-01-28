class ApplicationMailer < ActionMailer::Base
  default from: ENV["HOPHUB_MAIL_FROM"] || "noreply@devel.local"
  layout "mailer"

  def deliver
    if Rails.env.production?
      deliver_later
    else
      deliver_now
    end
  end
end
