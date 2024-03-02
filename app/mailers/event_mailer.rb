class EventMailer < ApplicationMailer
  def created
    @event = params[:event]
    mail(to: @event.admin_email,
         subject: t('mail.event.created.subject'))
  end

  def confirmed
    @event = params[:event]
    mail(to: @event.admin_email,
         bcc: ENV["HOPHUB_MAIL_EVENT_CONFIRMED_BCC"],
         subject: t('mail.event.confirmed.subject'))
  end
end
