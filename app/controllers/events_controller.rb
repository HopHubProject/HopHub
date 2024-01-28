class EventsController < ApplicationController
  before_action :find_event, only: [ :show, :edit, :update, :destroy, :confirm ]

  def show
    if @event.nil? or !@event.is_confirmed?
      redirect_to root_path, flash: { error: t('flash.event_not_found') }
      return
    end

    @admin = params[:admin_token] == @event.admin_token

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
    @description = markdown.render(@event.description)
  end

  def index
    redirect_to root_path
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.create(event_create_params)

    unless verify_altcha
      @event.errors.add(:altcha, t('not_a_human'))
      render 'new', status: :unprocessable_entity
      return
    end

    if @event.save
      EventMailer.with(event: @event).created.deliver
      redirect_to root_path, flash: { success: t('flash.event_created') }
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    if @event.nil?
      redirect_to root_path, flash: { error: t('flash.event_not_found') }
    elsif params[:admin_token] == @event.admin_token
      @event.destroy
      redirect_to root_path, flash: { success: t('flash.event_deleted') }
    else
      redirect_to event_path(@event)
    end
  end

  def confirm
    if @event.nil?
      redirect_to root_path, flash: { error: t('flash.event_not_found') }
      return
    end

    if @event.is_confirmed?
      redirect_to event_path(@event), flash: { error: t('flash.event_already_confirmed') }
    elsif params[:admin_token] == @event.admin_token
      @event.confirmed_at = Time.now
      @event.save
      EventMailer.with(event: @event).confirmed.deliver
      redirect_to event_path(@event), flash: { success: t('flash.event_confirmed') }
    else
      redirect_to event_path(@event)
    end
  end

  def edit
    if @event.nil?
      redirect_to root_path, flash: { error: t('flash.event_not_found') }
      return
    end

    if params[:admin_token] != @event.admin_token
      redirect_to event_path(@event)
    end
  end

  def update
    if @event.nil?
      redirect_to root_path, flash: { error: t('flash.event_not_found') }
      return
    end

    if params[:admin_token] != @event.admin_token
      redirect_to event_path(@event)
      return
    end

    @event.update(event_update_params)

    if @event.save
      redirect_to @event, flash: { success: 'Event was successfully updated.' }
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def geojson
    @event = Event.find(params[:event_id])
    @entry_type = params.permit(:entry_type)[:entry_type]
    @direction = params.permit(:direction)[:direction]

    if @event.nil? || @entry_type.nil? || @direction.nil?
      redirect_to root_path
      return
    end

    @entries = @event.entries.confirmed
      .where(entry_type: @entry_type, direction: @direction)

    features = @entries.map do |entry|
      {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [entry.longitude, entry.latitude]
        },
        properties: {
          url: event_entry_popup_path(@event, entry),
        }
      }
    end

    render json: {
      type: 'FeatureCollection',
      features: features
    }
  end

  private

  def verify_altcha
    return true if Rails.env.test?

    AltchaSolution.verify_and_save(params.permit(:altcha)[:altcha])
  end

  def find_event
    @event = Event.find(params[:id] || params[:event_id]) rescue nil
  end

  def event_create_params
    params.require(:event).permit(:name, :description, :admin_email, :end_date)
  end

  def event_update_params
    params.require(:event).permit(:name, :description, :end_date)
  end

end
