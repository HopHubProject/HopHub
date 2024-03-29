require "test_helper"

class ContentsControllerTest < ActionDispatch::IntegrationTest
  I18n.available_locales.each do |locale|
    define_method("test_should_get_imprint_#{locale}") do
      get imprint_url, params: { locale: locale }
      assert_response :success

      c = Content.for(:imprint, locale)
      assert @response.body.include?(c)
    end

    define_method("test_should_get_privacy_#{locale}") do
      get privacy_url, params: { locale: locale }
      assert_response :success

      c = Content.for(:privacy, locale)
      assert @response.body.include?(c)
    end

    define_method("test_should_get_tos_#{locale}") do
      get tos_url, params: { locale: locale }
      assert_response :success

      c = Content.for(:tos, locale)
      assert @response.body.include?(c)
    end
  end
end
