class RideRequestsController < ApplicationController
  before_action :find_event!
  before_action :find_ride_request!, only: [ :destroy, :destroy_confirm, :confirm ]
  before_action :set_geonames, only: [ :new, :create ]
  before_action :authenticate_user!, only: [ :destroy, :destroy_confirm, :confirm ]
  before_action :set_title
  before_action :set_meta_tags

  def new
    @ride_request = @event.ride_requests.new
    @ride_request.country = @event.default_country
    @ride_request.radius = 20
  end

  def create
    @ride_request = @event.ride_requests.new(ride_request_params)
    @ride_request.locale = I18n.locale.to_s
    @ride_request.valid?

    unless verify_altcha
      @ride_request.errors.add(:altcha, t('terms_and_conditions.error'))
      render 'new', status: :unprocessable_content
      return
    end

    if @ride_request.save
      RideRequestMailer.with(ride_request: @ride_request).created.deliver
      redirect_to @event, flash: { success: t('flash.ride_request_created') }
    else
      if @ride_request.errors[:latitude].any? || @ride_request.errors[:longitude].any?
        @ride_request.errors.add(:location, t('simple_form.errors.entry.location.invalid'))
      end

      @ride_request.country ||= @event.default_country

      render :new, status: :unprocessable_content
    end
  end

  def confirm
    if @ride_request.is_confirmed?
      redirect_to event_path(@event), flash: { error: t('flash.ride_request_already_confirmed') }
      return
    end

    if params[:token] != @ride_request.token
      redirect_to @event
      return
    end

    @ride_request.confirmed_at = Time.now
    @ride_request.save
    RideRequestMailer.with(ride_request: @ride_request).confirmed.deliver
    redirect_to event_path(@event), flash: { success: t('flash.ride_request_confirmed') }
  end

  def destroy_confirm
    # Renders the confirmation view; the actual deletion happens when the
    # form on that view submits a DELETE to the same URL.
  end

  def destroy
    @ride_request.destroy
    redirect_to @event, flash: { success: t('flash.ride_request_deleted') }
  end

  private

  def set_title
    super
    @title.push @event.name unless @event.nil?
  end

  def set_meta_tags
    @noindex = true
    @meta_description = t('meta.description.event', event_name: @event.name) if @event
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

  def find_ride_request!
    @ride_request = RideRequest.find(params[:id] || params[:ride_request_id]) rescue nil

    if @ride_request.nil?
      redirect_to @event, flash: { error: t('flash.ride_request_not_found') }
    end
  end

  def authenticate_user!
    token = params[:token] || params.dig(:ride_request, :token)

    if token != @ride_request.token
      redirect_to event_path(@event)
    end
  end

  def ride_request_params
    params.require(:ride_request).permit(:email, :direction, :location, :country, :latitude, :longitude, :radius, :start_date, :end_date)
  end

  def altcha_params
    params.permit(:altcha)
  end
end
