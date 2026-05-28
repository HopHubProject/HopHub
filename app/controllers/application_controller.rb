class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :set_title

  def set_title
    @title = [ "HopHub" ]
  end

  def set_locale
    I18n.locale = locale_for_request
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  protect_from_forgery with: :exception

  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_back(
      fallback_location: root_path,
      alert: "CSRF failed. Please try again."
    )
  end

  private

  def locale_for_request
    param_locale = params[:locale]
    return param_locale if param_locale.present? && I18n.available_locales.include?(param_locale.to_sym)

    http_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first rescue nil
    return http_locale if http_locale and I18n.available_locales.include? http_locale.to_sym

    I18n.default_locale
  end
end
