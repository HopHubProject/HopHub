class GdprInquiriesController < ApplicationController
  def new
    @inquiry = GdprInquiry.new
  end

  def create
    @inquiry = GdprInquiry.new
    @inquiry.email = inquiry_params[:email]

    altcha_ok = verify_altcha

    if @inquiry.invalid? || !altcha_ok
      unless altcha_ok
        @inquiry.errors.add(:altcha, t('terms_and_conditions.error'))
      end

      render 'new', status: :unprocessable_entity
      return
    end

    @events = Event.where("admin_email LIKE ?", @inquiry.email)
    @entries = Entry.where("email LIKE ?", @inquiry.email)

    GdprInquiryMailer.with(inquiry: @inquiry, events: @events, entries: @entries).response.deliver

    redirect_to root_path, flash: { success: t('flash.gdpr_inquiry_created') }
  end

  private

  def set_title
    super
    @title.push t('gdpr_inquiry.title')
  end

  def verify_altcha
    return true if Rails.env.test?

    AltchaSolution.verify_and_save(altcha_params[:altcha])
  end

  def inquiry_params
    params.require(:gdpr_inquiry).permit(:email)
  end

  def altcha_params
    params.permit(:altcha)
  end

end
