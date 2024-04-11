class GdprInquiryMailer < ApplicationMailer
  def response
    @inquiry = params[:inquiry]
    @events = params[:events]
    @entries = params[:entries]

    mail(to: @inquiry.email,
         bcc: ENV["HOPHUB_MAIL_GDPR_RESPONSE_BCC"],
         subject: t('mail.gdpr_inquiry.response.subject'))
  end
end
