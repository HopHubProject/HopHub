class EventsController < ApplicationController
  before_action :find_event!, only: [ :show, :edit, :update, :destroy, :confirm ]
  before_action :check_confirmed!, only: [ :show ]
  before_action :authenticate_user!, only: [ :edit, :update, :destroy, :confirm ]

  def show
    respond_to do |format|
      format.html do
        @entry_type = params.permit(:entry_type)[:entry_type] || :offer

        @way_there_count = @event.entries.confirmed.where(entry_type: @entry_type, direction: :way_there).count
        @way_back_count = @event.entries.confirmed.where(entry_type: @entry_type, direction: :way_back).count

        @offers_count = @event.entries.confirmed.where(entry_type: :offer).count
        @requests_count = @event.entries.confirmed.where(entry_type: :request).count

        @entries = @event.entries.confirmed.where(entry_type: @entry_type)
        @paginated_entries = @entries.page(params[:page])
      end

      format.json do
        render json: {
          name: @event.name,
          description: @event.description,
          end_date: @event.end_date,
          entries_current: @event.entries.confirmed.count,
          entries_added_total: @event.entries_added
        }
      end
    end
  end

  def index
    redirect_to root_path
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_create_params)

    unless verify_altcha
      @event.errors.add(:altcha, t('terms_and_conditions.error'))
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
    @event.destroy
    redirect_to root_path, flash: { success: t('flash.event_deleted') }
  end

  def confirm
    @event.confirmed_at = Time.now
    @event.save
    EventMailer.with(event: @event).confirmed.deliver
    redirect_to event_path(@event), flash: { success: t('flash.event_confirmed') }
  end

  def edit
  end

  def update
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

    if @event.nil? || !@event.is_confirmed? || @entry_type.nil? || @direction.nil?
      render json: { error: 'Not found' }, status: :not_found
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

    AltchaSolution.verify_and_save(altcha_params[:altcha])
  end

  def find_event!
    @event = Event.find(params[:id] || params[:event_id]) rescue nil

    if @event.nil?
      redirect_to root_path, flash: { error: t('flash.event_not_found') }
    end
  end

  def check_confirmed!
    if !@event.is_confirmed?
      redirect_to root_path, flash: { error: t('flash.event_not_found') }
    end
  end

  def authenticate_user!
    if params[:admin_token] != @event.admin_token
      redirect_to event_path(@event)
    end
  end

  def event_create_params
    params.require(:event).permit(:name, :description, :admin_email, :end_date)
  end

  def event_update_params
    params.require(:event).permit(:name, :description, :end_date)
  end

  def altcha_params
    params.permit(:altcha)
  end
end
