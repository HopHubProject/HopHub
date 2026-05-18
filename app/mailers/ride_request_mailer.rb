class RideRequestMailer < ApplicationMailer
  def created
    @ride_request = params[:ride_request]
    I18n.with_locale(@ride_request.locale) do
      mail(to: @ride_request.email,
           subject: t('mail.ride_request.created.subject'))
    end
  end

  def confirmed
    @ride_request = params[:ride_request]
    I18n.with_locale(@ride_request.locale) do
      mail(to: @ride_request.email,
           subject: t('mail.ride_request.confirmed.subject'))
    end
  end

  def offer_matched
    @ride_request = params[:ride_request]
    @offer = params[:offer]
    I18n.with_locale(@ride_request.locale) do
      mail(to: @ride_request.email,
           subject: t('mail.ride_request.offer_matched.subject'))
    end
  end
end
