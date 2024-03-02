class Content < ApplicationRecord
  def self.for(name, locale)
    r = where(name: name, locale: locale)
    if r.any?
      r.first.content
    else
      r = where(name: name, fallback: true)
      if r.any?
        r.first.content
      else
        ''
      end
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["content", "created_at", "fallback", "id", "id_value", "locale", "name", "updated_at"]
  end
end
