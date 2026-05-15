class RideRequest < ActiveRecord::Base
  belongs_to :event
  attr_accessor :country_input

  acts_as_mappable default_units:   :kms,
                   default_formula: :sphere,
                   lat_column_name: :latitude,
                   lng_column_name: :longitude

  DIRECTIONS = %w(way_there way_back)

  RADIUSES = EntriesFilter::RADIUSES

  validates_presence_of :event_id
  validates_presence_of :email
  validates_format_of :email, with: /\A[\w\-\.\+]+@([\w-]+\.)+[\w-]{2,}\z/

  validates_presence_of :direction
  validates_inclusion_of :direction, in: DIRECTIONS

  validates_presence_of :location
  validates_presence_of :country
  validates_presence_of :latitude
  validates_presence_of :longitude

  validates_presence_of :radius
  validates_inclusion_of :radius, in: RADIUSES.map { |_label, value| value }

  validates_presence_of :start_date
  validates_presence_of :end_date
  validate :end_date_in_future
  validate :start_date_before_end_date

  before_create :create_token
  before_create :create_id

  default_scope { order(created_at: :desc) }

  scope :confirmed,   -> { where("confirmed_at IS NOT NULL") }
  scope :unconfirmed, -> { where("confirmed_at IS NULL") }
  scope :way_there,   -> { where(direction: :way_there) }
  scope :way_back,    -> { where(direction: :way_back) }

  def is_confirmed?
    confirmed_at.present?
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
    ["confirmed_at", "created_at", "direction", "email", "end_date",
     "event_id", "id", "country", "latitude", "longitude", "location",
     "radius", "start_date", "token", "locale", "updated_at"]
  end

  def create_id
    self.id = SecureRandom.hex(6)
  end

  def create_token
    self.token = SecureRandom.hex(6)
  end

  def end_date_in_future
    if end_date && end_date < Time.now
      errors.add(:end_date, "should not be in the past")
    end
  end

  def start_date_before_end_date
    if start_date && end_date && start_date > end_date
      errors.add(:start_date, "must be before the latest arrival time")
    end
  end
end
