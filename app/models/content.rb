class Content < ApplicationRecord
  def self.for(name, locale)
    r = where(name: name, locale: locale)
    if r.any?
      return r.first
    end

    r = where(name: name, fallback: true)
    if r.any?
      return r.first
    end

    return nil
  end

  def self.ransackable_attributes(auth_object = nil)
    ["content", "created_at", "fallback", "id", "id_value", "locale", "name", "title", "updated_at"]
  end
end
