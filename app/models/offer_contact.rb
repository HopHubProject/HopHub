class OfferContact < ApplicationRecord
  belongs_to :offer

  KINDS = %w(phone sms signal whatsapp telegram instagram).freeze

  PHONE_PATTERN     = /\A\+[\d\s\-()]{6,}\z/.freeze
  SMS_PATTERN       = /\A\+[\d\s\-()]{6,}\z/.freeze
  SIGNAL_EU_PATTERN = %r{\Ahttps://signal\.me/\#eu/[A-Za-z0-9_\-]+\z}.freeze
  SIGNAL_PATTERN    = %r{\A(\+[\d\s\-()]{6,}|[a-zA-Z0-9_]{2,32}\.\d{2,}|https://signal\.me/\#eu/[A-Za-z0-9_\-]+)\z}.freeze
  WHATSAPP_PATTERN  = /\A\+[\d\s\-()]{6,}\z/.freeze
  TELEGRAM_PATTERN  = /\A(\+[\d\s\-()]{6,}|@?[a-zA-Z][a-zA-Z0-9_]{4,31})\z/.freeze
  INSTAGRAM_PATTERN = %r{\A(@?[A-Za-z0-9._]{1,30}|https?://(www\.)?instagram\.com/[A-Za-z0-9._]{1,30}/?)\z}.freeze

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :value, presence: true
  validate :validate_value_format

  def display_value
    case kind
    when "signal"    then value.to_s.match?(SIGNAL_EU_PATTERN) ? "Signal" : value
    when "instagram" then "@#{instagram_handle}"
    else                  value
    end
  end

  def link
    return nil if value.blank?

    case kind
    when "phone"
      "tel:#{normalized_phone}"
    when "sms"
      "sms:#{normalized_phone}"
    when "signal"
      if value.match?(SIGNAL_EU_PATTERN)
        value
      elsif value.start_with?("+")
        "https://signal.me/#p/#{normalized_phone}"
      else
        "https://signal.me/#u/#{value}"
      end
    when "whatsapp"
      # wa.me expects E.164 without the + sign
      "https://wa.me/#{normalized_phone.delete('+')}"
    when "telegram"
      if value.start_with?("+")
        "https://t.me/#{normalized_phone}"
      else
        "https://t.me/#{value.delete_prefix('@')}"
      end
    when "instagram"
      "https://instagram.com/#{instagram_handle}"
    end
  end

  def self.ransackable_associations(auth_object = nil)
    ["offer"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "offer_id", "kind", "value", "created_at", "updated_at"]
  end

  private

  def normalized_phone
    value.gsub(/[^\d+]/, "")
  end

  def instagram_handle
    value.to_s
         .sub(%r{\Ahttps?://(www\.)?instagram\.com/}, "")
         .delete_prefix("@")
         .delete_suffix("/")
  end

  def validate_value_format
    return if value.blank?

    pattern = case kind
              when "phone"     then PHONE_PATTERN
              when "sms"       then SMS_PATTERN
              when "signal"    then SIGNAL_PATTERN
              when "whatsapp"  then WHATSAPP_PATTERN
              when "telegram"  then TELEGRAM_PATTERN
              when "instagram" then INSTAGRAM_PATTERN
              end

    return unless pattern
    errors.add(:value, :invalid) unless value.match?(pattern)
  end
end
