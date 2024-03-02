class GdrpInquiryMailer < ApplicationMailer
  def response
    @inquiry = params[:inquiry]
    @events = params[:events]
    @entries = params[:entries]

    mail(to: @inquiry.email,
         bcc: ENV["HOPHUB_MAIL_GDRP_RESPONSE_BCC"],
         subject: t('mail.gdrp_inquiry.response.subject'))
  end
end
