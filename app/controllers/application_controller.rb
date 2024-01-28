class ApplicationController < ActionController::Base
  before_action :set_locale

  def set_locale
    I18n.locale = locale_for_request
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  private

  def locale_for_request
    return params[:locale] if params[:locale].present?

    http_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first rescue nil
    return http_locale if http_locale and I18n.available_locales.include? http_locale.to_sym

    I18n.default_locale
  end
end
