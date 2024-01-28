class EntryMailer < ApplicationMailer
  def created
    @entry = params[:entry]
    mail(to: @entry.email, subject: t('mail.entry.created.subject'))
  end

  def confirmed
    @entry = params[:entry]
    mail(to: @entry.email, subject: t('mail.entry.confirmed.subject'))
  end

  def contact
    @entry = params[:entry]
    @name = params[:name]
    @from = params[:from]
    @text = params[:text]

    I18n.with_locale(@entry.locale) do
      mail(to: @entry.email, reply_to: @from, subject: t('mail.entry.contact.subject'))
    end
  end
end
