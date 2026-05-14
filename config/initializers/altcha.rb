# frozen_string_literal: true

Altcha.setup do |config|
  if Rails.env.production?
    config.max_number = 50_000
  else
    config.max_number = 2
  end
  config.timeout = 5.minutes
  config.hmac_key = ENV['ALTCHA_HMAC_KEY'] || 'altcha'
end
