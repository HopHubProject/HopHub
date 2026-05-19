class OffersController < ApplicationController
  before_action :find_event!
  before_action :find_offer!, only: [ :show, :edit, :update, :destroy, :confirm, :contact_emails ]
  before_action :set_geonames, only: [ :new, :create, :edit, :update ]
  before_action :check_confirmed!, only: [ :show ]
  before_action :authenticate_user!, only: [ :edit, :update, :destroy, :confirm ]
  before_action :set_title
  before_action :set_meta_tags

  def index
    redirect_to @event
  end

  def show
    @contact_email = ContactEmail.new
  end

  def edit
    @offer.country ||= @event.default_country
  end

  def new
    @event = Event.find(params[:event_id])
    @offer = @event.offers.new
    @offer.seats = 1
    @offer.country = @event.default_country
  end

  def create
    @event = Event.find(params[:event_id])
    @offer = @event.offers.new(offer_params)
    @offer.locale = I18n.locale.to_s
    @offer.valid?

    unless verify_altcha
      @offer.errors.add(:altcha, t('terms_and_conditions.error'))
      render 'new', status: :unprocessable_content
      return
    end

    if @offer.save
      OfferMailer.with(offer: @offer).created.deliver
      redirect_to @event, flash: { success: t('flash.offer_created') }
    else
      if @offer.errors[:latitude].any? || @offer.errors[:longitude].any?
        @offer.errors.add(:location, t('simple_form.errors.offer.location.invalid'))
      end

      @offer.country ||= @event.default_country

      render :new, status: :unprocessable_content
    end
  end

  def update
    if @offer.update(offer_update_params)
      redirect_to event_offer_path(@event, @offer), flash: { success: t('flash.offer_updated') }
    else
      render 'edit', status: :unprocessable_content
    end
  end

  def confirm
    if @offer.is_confirmed?
      redirect_to event_offer_path(@event, @offer), flash: { error: t('flash.offer_already_confirmed') }
      return
    end

    if params[:token] != @offer.token
      redirect_to @event
      return
    end

    @offer.confirmed_at = Time.now
    @offer.save
    notified_count = notify_matching_ride_requests(@offer)
    OfferMailer.with(offer: @offer, notified_count: notified_count).confirmed.deliver

    flash_message = if notified_count > 0
                      t('flash.offer_confirmed_with_notifications', count: notified_count)
                    else
                      t('flash.offer_confirmed')
                    end
    redirect_to event_offer_path(@event, @offer), flash: { success: flash_message }
  end

  def destroy
    @offer.destroy
    redirect_to @event, flash: { success: t('flash.offer_deleted') }
  end

  def contact_emails
    p = params.require(:contact_email).permit(:name, :from, :text)
    @contact_email = ContactEmail.new
    @contact_email.name = p[:name]
    @contact_email.from = p[:from]
    @contact_email.text = p[:text]

    altcha_ok = verify_altcha

    if @contact_email.invalid? || !altcha_ok
        unless altcha_ok
          @contact_email.errors.add(:altcha, t('terms_and_conditions.error'))
        end

        render 'show', status: :unprocessable_content
      return
    end

    unless @event.shadow_banned?
      OfferMailer.with(
          offer: @offer,
          name: @contact_email.name,
          from: @contact_email.from,
          text: @contact_email.text).contact.deliver
    end

    redirect_to event_path(@event), flash: { success: t('flash.offer_contacted') }
  end

  private

  def set_title
    super
    @title.push @event.name unless @event.nil?
    @title.push @offer.name unless @offer.nil?
  end

  def set_meta_tags
    @noindex = true
    @meta_description = t('meta.description.offer', name: @offer.name, event_name: @event.name) if @offer
  end

  def verify_altcha
    return true if Rails.env.test?

    Altcha.verify(altcha_params[:altcha])
  end

  def set_geonames
    @countries = helpers.get_countries(I18n.locale.to_s)
  end

  def find_event!
    @event = Event.find(params[:event_id]) rescue nil

    if @event.nil?
      redirect_to root_path, flash: { error: t('flash.event_not_found') }
    end
  end

  def find_offer!
    @offer = Offer.find(params[:id] || params[:offer_id]) rescue nil

    if @offer.nil?
      redirect_to @event, flash: { error: t('flash.offer_not_found') }
    end
  end

  def check_confirmed!
    if !@offer.is_confirmed?
      redirect_to @event, flash: { error: t('flash.offer_not_found') }
    end
  end

  def authenticate_user!
    token = params[:token] || params.dig(:offer, :token)

    if token != @offer.token
      redirect_to event_path(@event)
    end
  end

  def offer_params
    params.require(:offer).permit(:name, :email, :transport, :phone, :driver,
                                  :direction, :date, :location, :country, :latitude, :longitude, :seats, :notes)
  end

  def offer_update_params
    params.require(:offer).permit(:name, :transport, :phone, :date, :driver, :location, :country, :latitude, :longitude, :seats, :notes)
  end

  def altcha_params
    params.permit(:altcha)
  end

  def notify_matching_ride_requests(offer)
    return 0 unless offer.latitude.present? && offer.longitude.present? && offer.date.present?

    # Direction, time-window, and "has a radius" are cheap to filter in SQL.
    # The distance check stays in Ruby: geokit-rails' geo helpers compare
    # against a constant radius, not against the per-row `radius` column.
    candidates = offer.event.ride_requests.confirmed
      .where(direction: offer.direction)
      .where.not(radius: nil)
      .where("start_date IS NULL OR start_date <= ?", offer.date)
      .where("end_date   IS NULL OR end_date   >= ?", offer.date)

    origin = [offer.latitude, offer.longitude]
    notified = 0

    candidates.find_each do |ride_request|
      next if ride_request.distance_to(origin) > ride_request.radius

      RideRequestMailer.with(ride_request: ride_request, offer: offer).offer_matched.deliver
      notified += 1
    end

    notified
  end
end
