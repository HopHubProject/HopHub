class EntriesFilter
  include ActiveModel::Model

  attr_accessor :location, :country, :latitude, :longitude, :radius

  RADIUSES = [['+ 5 km', 5], ['+ 10 km', 10], ['+ 20 km', 20], ['+ 50 km', 50], ['+ 100 km', 100]].freeze

  def initialize(params = {})
    super(params || {})

    unless self.latitude.present? && self.longitude.present?
      self.location = ""
      self.radius = 0
      self.latitude = nil
      self.longitude = nil
    end
  end

  def apply(entries)
    Rails.logger.info "Applying filter with params: #{self.location} #{self.latitude} #{self.longitude} #{self.radius}"

    return entries unless location.present? && latitude.present? && longitude.present? && radius.present?

    point = [latitude, longitude]
    r = radius.to_s.to_i

    entries.in_range(0..r, origin: point)
  end

  def active?
    location.present? && latitude.present? && longitude.present? && radius.present?
  end

  def persisted?
    false
  end
end
