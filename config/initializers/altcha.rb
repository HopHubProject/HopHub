# frozen_string_literal: true

Altcha.setup do |config|
  config.algorithm = 'SHA-256'
  if Rails.env.production?
    config.num_range = (10_000..50_000)
  else
    config.num_range = (1..2)
  end
  config.timeout = 5.minutes
  config.hmac_key = ENV['ALTCHA_HMAC_KEY'] || 'altcha'
end
