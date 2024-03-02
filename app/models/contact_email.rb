class ContactEmail
  include ActiveModel::Validations

  attr_accessor :name, :from, :text

  validates_presence_of :name
  validates_length_of :name, maximum: 100

  validates_presence_of :from
  validates_format_of :from, with: /\A[\w\-\.]+@([\w-]+\.)+[\w-]{2,}\z/

  validates_presence_of :text
  validates_length_of :text, maximum: 1000

  def to_key
    nil
  end

  def to_model
    self
  end

  def persisted?
    false
  end
end


