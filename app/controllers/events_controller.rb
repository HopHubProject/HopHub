class EventsController < ApplicationController
  before_action :find_event!, only: [ :show, :edit, :update, :destroy, :confirm ]
  before_action :check_confirmed!, only: [ :show ]
  before_action :authenticate_user!, only: [ :edit, :update, :destroy, :confirm ]
  before_action :set_noindex, only: [ :show, :edit, :update, :destroy, :confirm ]
  before_action :set_title
  before_action :set_geonames, only: [ :new, :edit, :create, :show ]

  def show
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})

    @description = markdown.render(@event.description)

    @way_there_count = @event.entries.confirmed.where(direction: :way_there).count
    @way_back_count = @event.entries.confirmed.where(direction: :way_back).count
    @offers_count = @event.entries.confirmed.count

    p = params.fetch(:entries_filter, ActionController::Parameters.new).permit(:location, :latitude, :longitude, :radius)
    @filter = EntriesFilter.new(p)
    @filter.country ||= @event.default_country

    Rails.logger.info "Filter params: #{p.inspect}"

    @entries = @event.entries.confirmed.in_future
    @filtered_entries = @filter.apply(@entries)
    @paginated_entries = @filtered_entries.page(params[:page])
  end

  def index
    redirect_to root_path
  end

  def new
    @event = Event.new
  end

  def create
    if ENV['HOPHUB_SINGLE_EVENT_ID'].present?
      redirect_to root_path
      return
    end

    @event = Event.new(event_create_params)
    @event.valid?

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
    if @event.is_confirmed?
      redirect_to event_path(@event), flash: { error: t('flash.event_already_confirmed') }
      return
    end

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

  private

  def set_title
    super
    @title.push @event.name unless @event.nil?
  end

  def set_noindex
    @noindex = true
  end

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

  def set_geonames
    @countries = helpers.get_countries(I18n.locale.to_s)
  end

  def authenticate_user!
    token = params[:admin_token] || params.dig(:event, :admin_token)

    if token != @event.admin_token
      redirect_to event_path(@event)
    end
  end

  def event_create_params
    params.require(:event).permit(:name, :description, :admin_email, :end_date, :default_country)
  end

  def event_update_params
    params.require(:event).permit(:name, :description, :end_date, :default_country)
  end

  def altcha_params
    params.permit(:altcha)
  end
end
