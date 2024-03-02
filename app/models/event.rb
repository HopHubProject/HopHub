class Event < ActiveRecord::Base
  has_many :entries, dependent: :destroy

  validates_presence_of :name
  validates_length_of :name, maximum: 30

  validates_presence_of :description
  validates_length_of :description, maximum: 10000

  validates_presence_of :end_date
  validate :end_date_in_future

  validates_presence_of :admin_email
  validates_format_of :admin_email, with: /\A[\w\-\.]+@([\w-]+\.)+[\w-]{2,}\z/

  default_scope { order(created_at: :asc) }

  scope :confirmed, -> { where("confirmed_at IS NOT NULL") }
  scope :unconfirmed, -> { where("confirmed_at IS NULL") }

  def is_confirmed?
    confirmed_at.present?
  end

  def offers
    entries.confirmed.offer
  end

  def requests
    entries.confirmed.request
  end

  def requests_way_there
    entries.confirmed.in_future.request.way_there
  end

  def offers_way_there
    entries.confirmed.in_future.offer.way_there
  end

  def requests_way_back
    entries.confirmed.in_future.request.way_back
  end

  def offers_way_back
    entries.confirmed.in_future.offer.way_back
  end

  before_create :create_admin_token
  before_create :create_id

  private

  def self.ransackable_associations(auth_object = nil)
    ["entries"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["admin_email", "admin_token", "confirmed_at", "created_at", "description",
     "end_date", "id", "id_value", "name", "shadow_banned", "updated_at", "entries_added"]
  end

  def create_id
    id = self.name.
      gsub(/[^a-z0-9\-]+/i, '-').
      gsub(/--+/, '-').
      gsub(/^-|-$/, '').
      downcase

    if id.length < 10
      random_length = 4
    else
      random_length = 3
    end

    loop do
      self.id = id + "-" + SecureRandom.hex(random_length)
      break unless Event.exists?(id: self.id)
    end
  end

  def create_admin_token
    self.admin_token = SecureRandom.hex(8)
  end

  def end_date_in_future
    if self.end_date and self.end_date < Time.now
      self.errors.add(:end_date, "should not be in the past")
    end
  end
end
