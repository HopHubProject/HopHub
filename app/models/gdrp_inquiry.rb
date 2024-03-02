class GdrpInquiry
  include ActiveModel::Validations

  attr_accessor :email

  validates_presence_of :email
  validates_format_of :email, with: /\A[\w\-\.]+@([\w-]+\.)+[\w-]{2,}\z/

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


