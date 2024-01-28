class EntriesController < ApplicationController
  before_action :find_event!
  before_action :find_entry!, only: [ :show, :edit, :update, :popup, :destroy, :confirm, :contact_emails ]
  before_action :check_direction_and_entry_type!, only: [ :index, :new, :create ]
  before_action :check_confirmed!, only: [ :show, :popup ]
  before_action :authenticate_user!, only: [ :edit, :update, :destroy, :confirm ]

  def index
    @q = params.permit(:q)[:q]

    @way_there_count = @event.entries.confirmed.where(entry_type: @entry_type, direction: :way_there).count
    @way_back_count = @event.entries.confirmed.where(entry_type: @entry_type, direction: :way_back).count

    @entries = @event.entries.confirmed
      .where(entry_type: @entry_type, direction: @direction)

    if @q.present?
      @entries = @entries.where("name LIKE ? OR location LIKE ?", "%#{@q}%", "%#{@q}%")
    end

    @paginated_entries = @entries.page(params[:page])
  end

  def show
    @contact_email = ContactEmail.new
  end

  def popup
    if @event.nil?
      head :not_found
      return
    end

    if @entry.nil? || !@entry.is_confirmed?
      head :not_found
      return
    end

    render layout: false
  end

  def new
    @event = Event.find(params[:event_id])
    @entry = @event.entries.new
    @entry.entry_type = params.permit(:entry_type)[:entry_type]
    @entry.direction = params.permit(:direction)[:direction]
    @entry.seats = 1

    if @entry.entry_type.nil? || @entry.direction.nil?
      redirect_to @event
    end
  end

  def create
    @event = Event.find(params[:event_id])
    @entry = @event.entries.create(entry_params)

    unless verify_altcha
      @entry.errors.add(:altcha, t('not_a_human'))
      render 'new', status: :unprocessable_entity
      return
    end

    if @entry.errors[:latitude].any? || @entry.errors[:longitude].any?
      @entry.errors.add(:location, t('simple_form.errors.entry.location.invalid'))
      render 'new', status: :unprocessable_entity
      return
    end

    @entry.locale = I18n.locale.to_s

    if @entry.save
      EntryMailer.with(entry: @entry).created.deliver
      redirect_to @event, flash: { success: t('flash.entry_created') }
    else
      if @entry.errors[:entry_type].any? || @entry.errors[:direction].any?
        redirect_to @event
        return
      end

      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @entry.update(entry_update_params)
      redirect_to event_entry_path(@event, @entry), flash: { success: t('flash.entry_updated') }
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def edit
  end

  def confirm
    if @entry.is_confirmed?
      redirect_to event_entry_path(@event, @entry), flash: { error: t('flash.entry_already_confirmed') }
      return
    end

    if params[:token] != @entry.token
      redirect_to @event
      return
    end

    @entry.confirmed_at = Time.now
    @entry.save
    EntryMailer.with(entry: @entry).confirmed.deliver
    redirect_to event_entry_path(@event, @entry), flash: { success: t('flash.entry_confirmed') }
  end

  def destroy
    @entry.destroy
    redirect_to @event, flash: { success: t('flash.entry_deleted') }
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
          @contact_email.errors.add(:altcha, t('not_a_human'))
        end

        render 'show', status: :unprocessable_entity
      return
    end

    unless @event.shadow_banned?
      EntryMailer.with(
          entry: @entry,
          name: @contact_email.name,
          from: @contact_email.from,
          text: @contact_email.text).contact.deliver
    end

    redirect_to event_entry_path(@event, @entry), flash: { success: t('flash.entry_contacted') }
  end

  private

  def verify_altcha
    return true if Rails.env.test?

    AltchaSolution.verify_and_save(params.permit(:altcha)[:altcha])
  end

  def find_event!
    @event = Event.find(params[:event_id]) rescue nil

    if @event.nil?
      redirect_to root_path, flash: { error: t('flash.event_not_found') }
    end
  end

  def find_entry!
    @entry = Entry.find(params[:id] || params[:entry_id]) rescue nil

    if @entry.nil?
      redirect_to @event, flash: { error: t('flash.entry_not_found') }
    end
  end

  def check_confirmed!
    if !@entry.is_confirmed?
      redirect_to @event, flash: { error: t('flash.entry_not_found') }
    end
  end

  def check_direction_and_entry_type!
    @entry_type = params.permit(:entry_type)[:entry_type] || params.dig(:entry, :entry_type)
    @direction = params.permit(:direction)[:direction]    || params.dig(:entry, :direction)

    if @entry_type.nil? || !Entry::TYPES.include?(@entry_type) ||
       @direction.nil?  || !Entry::DIRECTIONS.include?(@direction)
      redirect_to @event
      return
    end
  end

  def authenticate_user!
    token = params[:token] || params.dig(:entry, :token)

    if token != @entry.token
      redirect_to event_path(@event)
    end
  end

  def entry_params
    params.require(:entry).permit(:name, :email, :transport, :phone, :entry_type, :direction, :date, :location, :latitude, :longitude, :seats, :notes)
  end

  def entry_update_params
    params.require(:entry).permit(:name, :transport, :phone, :date, :location, :latitude, :longitude, :seats, :notes)
  end
end
