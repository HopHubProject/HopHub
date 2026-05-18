class OfferMailer < ApplicationMailer
  def created
    @offer = params[:offer]
    mail(to: @offer.email,
         subject: t('mail.offer.created.subject'))
  end

  def confirmed
    @offer = params[:offer]
    @notified_count = params[:notified_count].to_i
    mail(to: @offer.email,
         subject: t('mail.offer.confirmed.subject'))
  end

  def contact
    @offer = params[:offer]
    @name = params[:name]
    @from = params[:from]
    @text = params[:text]

    I18n.with_locale(@offer.locale) do
      mail(to: @offer.email,
           reply_to: @from,
           subject: t('mail.offer.contact.subject'))
    end
  end
end
