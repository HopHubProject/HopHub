class Entry < ActiveRecord::Base
  belongs_to :event

  TRANSPORTS = %w(any car train bus bicycle foot other)
  DIRECTIONS = %w(way_there way_back)
  TYPES = %w(request offer)

  validates_presence_of :event_id
  validates_presence_of :name

  validates_presence_of :email
  validates_format_of :email, with: /\A[\w\-\.]+@([\w-]+\.)+[\w-]{2,}\z/

  validates_presence_of :transport
  validates_inclusion_of :transport, in: TRANSPORTS

  validates_presence_of :entry_type
  validates_inclusion_of :entry_type, in: TYPES

  validates_presence_of :direction
  validates_inclusion_of :direction, in: DIRECTIONS

  validates_presence_of :seats
  validates_numericality_of :seats

  validates_presence_of :date
  validate :date_in_future

  validates_presence_of :location

  validates_presence_of :longitude
  validates_presence_of :latitude

  before_create :create_token
  before_create :create_id

  after_create :increase_event_entries_count

  default_scope { order(date: :asc) }

  scope :in_future,   -> { where("date >= ?", Time.now-3.hours) }
  scope :confirmed,   -> { where("confirmed_at IS NOT NULL") }
  scope :unconfirmed, -> { where("confirmed_at IS NULL") }
  scope :request,     -> { where(entry_type: :request) }
  scope :offer,       -> { where(entry_type: :offer) }
  scope :way_there,   -> { where(direction: :way_there) }
  scope :way_back,    -> { where(direction: :way_back) }

  def is_confirmed?
    confirmed_at.present?
  end

  def is_offer?
    entry_type.to_sym == :offer
  end

  def is_request?
    entry_type.to_sym == :request
  end

  def is_way_there?
    direction.to_sym == :way_there
  end

  def is_way_back?
    direction.to_sym == :way_back
  end

  private

  def self.ransackable_associations(auth_object = nil)
    ["event"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["confirmed_at", "created_at", "date", "direction", "email", "entry_type",
     "event_id", "id", "id_value", "transport", "longitude", "latitude", "location",
     "driver", "name", "notes", "phone", "seats", "token", "locale", "updated_at"]
  end

  def increase_event_entries_count
    event.increment!(:entries_added)
  end

  def create_id
    self.id = SecureRandom.hex(6)
  end

  def create_token
    self.token = SecureRandom.hex(6)
  end

  def date_in_future
    if self.date and self.date < Time.now
      self.errors.add(:date, "should not be in the past")
    end
  end
end
